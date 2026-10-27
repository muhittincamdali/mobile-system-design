import Foundation

/// A client-side rate limiter: a bucket of tokens that refills at a fixed rate.
///
/// Each request takes tokens; when the bucket is empty, requests wait or are dropped. Bursts up
/// to ``capacity`` pass at once, and the long-run rate is ``refillPerSecond``. Typical uses are
/// search-as-you-type, analytics uploads and "pull to refresh" spam.
///
/// ```swift
/// var limiter = TokenBucket(capacity: 5, refillPerSecond: 1)
/// if limiter.tryConsume() {
///     await search(query)
/// }
/// ```
///
/// `TokenBucket` is a value type; keep it in an actor when several tasks share it.
public struct TokenBucket: Sendable, Hashable {
    /// The most tokens the bucket holds, which is the largest burst.
    public let capacity: Double
    /// Tokens added per second.
    public let refillPerSecond: Double

    private var tokens: Double
    private var lastRefill: ContinuousClock.Instant

    /// Creates a full bucket.
    ///
    /// NaN, infinite and negative values are treated as zero; a bucket with zero capacity
    /// refuses every request.
    public init(capacity: Double, refillPerSecond: Double, now: ContinuousClock.Instant = .now) {
        self.capacity = Self.sanitized(capacity)
        self.refillPerSecond = Self.sanitized(refillPerSecond)
        self.tokens = self.capacity
        self.lastRefill = now
    }

    /// The tokens available at `now`.
    public func availableTokens(at now: ContinuousClock.Instant = .now) -> Double {
        var copy = self
        copy.refill(at: now)
        return copy.tokens
    }

    /// Takes `count` tokens if the bucket has them.
    ///
    /// - Parameters:
    ///   - count: The tokens to take; must be a positive, finite number. Any other value is
    ///     refused.
    ///   - now: The current time, used to add the tokens refilled since the last call.
    /// - Returns: `true` when the tokens were taken.
    public mutating func tryConsume(_ count: Double = 1, at now: ContinuousClock.Instant = .now) -> Bool {
        guard count.isFinite, count > 0 else { return false }
        refill(at: now)
        guard tokens >= count else { return false }
        tokens -= count
        return true
    }

    /// How long until `count` tokens are available, or `nil` when they never will be because
    /// `count` is above ``capacity`` (or the bucket does not refill).
    public func timeUntilAvailable(_ count: Double = 1, at now: ContinuousClock.Instant = .now) -> Duration? {
        guard count.isFinite, count > 0, count <= capacity else { return nil }
        let available = availableTokens(at: now)
        if available >= count { return .zero }
        guard refillPerSecond > 0 else { return nil }
        let seconds = (count - available) / refillPerSecond
        return Duration.clampedSeconds(seconds, limit: .seconds(Int64.max / 2))
    }

    private mutating func refill(at now: ContinuousClock.Instant) {
        // A clock reading older than the last one (it cannot happen with ContinuousClock, but a
        // test or a caller can pass one) adds nothing instead of removing tokens.
        guard now > lastRefill else { return }
        let elapsed = (now - lastRefill).secondsValue
        tokens = min(capacity, tokens + elapsed * refillPerSecond)
        lastRefill = now
    }

    private static func sanitized(_ value: Double) -> Double {
        value.isFinite && value > 0 ? value : 0
    }
}
