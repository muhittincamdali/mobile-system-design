import Foundation

/// Runs an async operation again when it fails with a temporary error.
///
/// ```swift
/// let retrier = Retrier(policy: RetryPolicy(maxAttempts: 4))
/// let data = try await retrier.run { attempt in
///     try await api.fetchFeed()
/// }
/// ```
///
/// Each failure is classified by `classify` (``RetryDecision/classify(_:)`` by default). The
/// retrier stops at the first permanent error, after ``RetryPolicy/maxAttempts`` attempts, when
/// the task is cancelled, or when a server asks for a wait longer than
/// ``RetryPolicy/maxDelay``; it then rethrows the last error unchanged.
///
/// The sleep function and the random source are injectable, so tests run instantly and see
/// exact delays.
public struct Retrier: Sendable {
    /// The policy that decides the number of attempts and the waits.
    public let policy: RetryPolicy
    private let sleep: @Sendable (Duration) async throws -> Void
    private let random: @Sendable () -> Double

    /// Creates a retrier.
    ///
    /// - Parameters:
    ///   - policy: Attempts and delays.
    ///   - sleep: Waits between attempts; it must throw `CancellationError` when the task is
    ///     cancelled, as `Task.sleep(for:)` does.
    ///   - random: Returns a number in `0..<1` for jitter.
    public init(
        policy: RetryPolicy = .default,
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) },
        random: @escaping @Sendable () -> Double = { Double.random(in: 0..<1) }
    ) {
        self.policy = policy
        self.sleep = sleep
        self.random = random
    }

    /// Runs `operation` until it succeeds or the retrier gives up.
    ///
    /// The operation and the classifier run on the caller's actor.
    ///
    /// - Parameters:
    ///   - isolation: The actor to run the operation on; the caller's by default.
    ///   - classify: Decides whether an error is worth another attempt.
    ///   - operation: The work to run. It receives the attempt number, starting at 1.
    /// - Returns: The operation's result.
    /// - Throws: The last error of the operation, or `CancellationError`.
    public func run<T>(
        isolation: isolated (any Actor)? = #isolation,
        classify: (any Error) -> RetryDecision = RetryDecision.classify,
        _ operation: (_ attempt: Int) async throws -> T
    ) async throws -> T {
        var attempt = 1
        while true {
            try Task.checkCancellation()
            do {
                return try await operation(attempt)
            } catch {
                guard attempt < policy.maxAttempts else { throw error }
                let wait: Duration
                switch classify(error) {
                case .doNotRetry:
                    throw error
                case .retry:
                    wait = policy.delay(afterAttempt: attempt, randomUnit: random())
                case .retryAfter(let requested):
                    guard requested <= policy.maxDelay else { throw error }
                    wait = max(.zero, requested)
                }
                try await sleep(wait)
                attempt += 1
            }
        }
    }
}
