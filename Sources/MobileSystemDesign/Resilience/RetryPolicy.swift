import Foundation

/// How many times to try an operation and how long to wait between tries.
///
/// The wait grows exponentially: `initialDelay × multiplier^(attempt − 1)`, capped at
/// ``maxDelay``. ``Jitter`` spreads the waits of many clients over time, so that thousands of
/// phones that lost the connection at the same moment do not all retry at the same moment.
///
/// Policies often come from remote configuration, so the initializer clamps values instead of
/// trapping: `maxAttempts` is kept between 1 and ``attemptLimit``, negative delays become zero,
/// and a multiplier below 1 (or NaN) becomes 1.
public struct RetryPolicy: Sendable, Hashable {
    /// How the wait is randomized.
    public enum Jitter: Sendable, Hashable {
        /// Wait exactly the computed delay.
        case none
        /// Wait a random time between zero and the computed delay. It spreads retries the most.
        case full
        /// Wait half of the computed delay plus a random part of the other half.
        case equal
    }

    /// The largest `maxAttempts` a policy accepts.
    public static let attemptLimit = 100

    /// Three attempts, 200 ms initial delay doubling up to 30 seconds, with full jitter.
    public static let `default` = RetryPolicy()

    /// The total number of attempts, including the first one.
    public let maxAttempts: Int
    /// The delay after the first failed attempt, before jitter.
    public let initialDelay: Duration
    /// The factor the delay grows by after each failed attempt.
    public let multiplier: Double
    /// The longest delay between two attempts. A server's `Retry-After` above this value ends
    /// the retries instead of making the user wait.
    public let maxDelay: Duration
    /// How the delay is randomized.
    public let jitter: Jitter

    /// Creates a policy.
    public init(
        maxAttempts: Int = 3,
        initialDelay: Duration = .milliseconds(200),
        multiplier: Double = 2,
        maxDelay: Duration = .seconds(30),
        jitter: Jitter = .full
    ) {
        self.maxAttempts = min(max(1, maxAttempts), Self.attemptLimit)
        self.initialDelay = max(.zero, initialDelay)
        self.multiplier = multiplier.isNaN || multiplier < 1 ? 1 : multiplier
        self.maxDelay = max(.zero, maxDelay)
        self.jitter = jitter
    }

    /// The wait after the given failed attempt.
    ///
    /// - Parameters:
    ///   - attempt: The number of the attempt that failed, starting at 1. Values below 1 count
    ///     as 1.
    ///   - randomUnit: A random number in `0..<1` used for jitter. Values outside that range are
    ///     clamped, and NaN counts as zero, so a broken random source cannot produce an invalid
    ///     delay.
    public func delay(afterAttempt attempt: Int, randomUnit: Double) -> Duration {
        let initial = initialDelay.secondsValue
        let cap = maxDelay.secondsValue
        var base = 0.0
        if initial > 0 {
            let growth = Foundation.pow(multiplier, Double(max(1, attempt) - 1))
            // `growth` is +infinity for large attempts; the product then is too, and min caps it.
            base = Swift.min(initial * growth, cap)
        }
        let unit = randomUnit.isNaN ? 0 : Swift.min(Swift.max(randomUnit, 0), 1)
        let seconds: Double
        switch jitter {
        case .none: seconds = base
        case .full: seconds = base * unit
        case .equal: seconds = base / 2 + base / 2 * unit
        }
        return Duration.clampedSeconds(seconds, limit: maxDelay)
    }
}
