import Foundation

extension Duration {
    /// The duration in seconds as a `Double`.
    var secondsValue: Double {
        let parts = components
        return Double(parts.seconds) + Double(parts.attoseconds) / 1e18
    }

    /// Converts seconds to a duration without trapping.
    ///
    /// `Duration.seconds(_:)` traps on NaN and infinity. Here NaN and negative values become
    /// zero, and values above `limit` (or infinity) become `limit`.
    static func clampedSeconds(_ seconds: Double, limit: Duration) -> Duration {
        guard !seconds.isNaN, seconds > 0 else { return .zero }
        let limitSeconds = limit.secondsValue
        guard seconds < limitSeconds else { return limit }
        return .seconds(seconds)
    }
}
