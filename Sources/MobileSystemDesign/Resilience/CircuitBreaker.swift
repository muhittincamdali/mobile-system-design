import Foundation

/// Stops calling a failing dependency for a while, so the app fails fast instead of waiting on
/// timeouts and the server gets room to recover.
///
/// The breaker is **closed** while calls succeed. After ``Configuration/failureThreshold``
/// failures in a row it **opens**: calls fail immediately with
/// ``CircuitBreakerError/open(retryAfter:)`` for ``Configuration/openDuration``. Then it is
/// **half-open**: up to ``Configuration/halfOpenProbeLimit`` calls go through as probes. A
/// successful probe closes the breaker; a failed one opens it again.
///
/// ```swift
/// let breaker = CircuitBreaker()
/// let feed = try await breaker.run { try await api.fetchFeed() }
/// ```
///
/// Results of calls that started before the breaker changed state are ignored, so a slow call
/// that fails after a probe already succeeded cannot reopen the breaker.
public actor CircuitBreaker {
    /// The breaker's settings.
    public struct Configuration: Sendable, Hashable {
        /// Consecutive failures that open the breaker. At least 1.
        public let failureThreshold: Int
        /// How long the breaker stays open before it lets probes through.
        public let openDuration: Duration
        /// How many probe calls may run at the same time while half-open. At least 1.
        public let halfOpenProbeLimit: Int

        /// Creates a configuration; values below the minimum are raised to it.
        public init(failureThreshold: Int = 5, openDuration: Duration = .seconds(30), halfOpenProbeLimit: Int = 1) {
            self.failureThreshold = max(1, failureThreshold)
            self.openDuration = max(.zero, openDuration)
            self.halfOpenProbeLimit = max(1, halfOpenProbeLimit)
        }
    }

    /// The breaker's state.
    public enum State: Sendable, Hashable {
        /// Calls go through; `failures` counts consecutive failures.
        case closed(failures: Int)
        /// Calls fail fast until `until`.
        case open(until: ContinuousClock.Instant)
        /// A limited number of probe calls go through.
        case halfOpen(probesInFlight: Int)
    }

    /// Permission to make one call, returned by ``acquire()``.
    public struct Permit: Sendable {
        fileprivate let generation: Int
        fileprivate let isProbe: Bool
    }

    /// The configuration.
    public nonisolated let configuration: Configuration
    /// The current state.
    public private(set) var state: State = .closed(failures: 0)

    private let now: @Sendable () -> ContinuousClock.Instant
    private let countsAsFailure: @Sendable (any Error) -> Bool
    private var generation = 0

    /// Creates a closed breaker.
    ///
    /// - Parameters:
    ///   - configuration: Thresholds and durations.
    ///   - countsAsFailure: Whether an error says the dependency is unhealthy. The default
    ///     ignores cancellation and ``HTTPStatusError``s below 500: a 404 means the request was
    ///     wrong, not that the server is down.
    ///   - now: The clock; inject one in tests.
    public init(
        configuration: Configuration = Configuration(),
        countsAsFailure: @escaping @Sendable (any Error) -> Bool = CircuitBreaker.defaultFailureFilter,
        now: @escaping @Sendable () -> ContinuousClock.Instant = { ContinuousClock.now }
    ) {
        self.configuration = configuration
        self.countsAsFailure = countsAsFailure
        self.now = now
    }

    /// The default failure filter. See ``init(configuration:countsAsFailure:now:)``.
    public static let defaultFailureFilter: @Sendable (any Error) -> Bool = { error in
        if error is CancellationError { return false }
        if let status = error as? HTTPStatusError { return status.statusCode >= 500 || status.statusCode == 429 }
        if let urlError = error as? URLError, urlError.code == .cancelled { return false }
        return true
    }

    /// Asks to make a call.
    ///
    /// - Returns: A permit to pass to ``recordSuccess(_:)`` or ``recordFailure(_:)``.
    /// - Throws: ``CircuitBreakerError/open(retryAfter:)`` while the breaker is open or all
    ///   probe slots are taken.
    public func acquire() throws -> Permit {
        let current = now()
        switch state {
        case .closed:
            return Permit(generation: generation, isProbe: false)
        case .open(let until):
            guard current >= until else {
                throw CircuitBreakerError.open(retryAfter: until - current)
            }
            transition(to: .halfOpen(probesInFlight: 1))
            return Permit(generation: generation, isProbe: true)
        case .halfOpen(let probes):
            guard probes < configuration.halfOpenProbeLimit else {
                throw CircuitBreakerError.open(retryAfter: .zero)
            }
            state = .halfOpen(probesInFlight: probes + 1)
            return Permit(generation: generation, isProbe: true)
        }
    }

    /// Records that the call made with `permit` succeeded.
    public func recordSuccess(_ permit: Permit) {
        guard permit.generation == generation else { return }
        switch state {
        case .closed:
            state = .closed(failures: 0)
        case .halfOpen:
            transition(to: .closed(failures: 0))
        case .open:
            break
        }
    }

    /// Records that the call made with `permit` failed.
    public func recordFailure(_ permit: Permit) {
        guard permit.generation == generation else { return }
        switch state {
        case .closed(let failures):
            let count = failures + 1
            if count >= configuration.failureThreshold {
                transition(to: .open(until: now() + configuration.openDuration))
            } else {
                state = .closed(failures: count)
            }
        case .halfOpen:
            transition(to: .open(until: now() + configuration.openDuration))
        case .open:
            break
        }
    }

    /// Records that the call made with `permit` ended without telling anything about the
    /// dependency's health, for example because it was cancelled. A probe slot is released.
    public func recordIgnored(_ permit: Permit) {
        guard permit.generation == generation, permit.isProbe, case .halfOpen(let probes) = state else { return }
        state = .halfOpen(probesInFlight: max(0, probes - 1))
    }

    /// Closes the breaker and forgets the failures, for example after the network changed.
    public func reset() {
        transition(to: .closed(failures: 0))
    }

    /// Runs `operation` through the breaker.
    ///
    /// - Parameters:
    ///   - isolation: The actor to run the operation on; the caller's by default.
    ///   - operation: The call to make.
    ///
    /// - Throws: ``CircuitBreakerError/open(retryAfter:)`` without running the operation while
    ///   the breaker is open, otherwise the operation's own error.
    public func run<T>(
        isolation: isolated (any Actor)? = #isolation,
        _ operation: () async throws -> T
    ) async throws -> T {
        let permit = try await acquire()
        do {
            let value = try await operation()
            await recordSuccess(permit)
            return value
        } catch {
            if countsAsFailure(error) {
                await recordFailure(permit)
            } else {
                await recordIgnored(permit)
            }
            throw error
        }
    }

    private func transition(to newState: State) {
        generation &+= 1
        state = newState
    }
}

/// The error a ``CircuitBreaker`` throws instead of running a call.
public enum CircuitBreakerError: Error, Sendable, Hashable {
    /// The breaker is open; try again after `retryAfter`.
    case open(retryAfter: Duration)
}
