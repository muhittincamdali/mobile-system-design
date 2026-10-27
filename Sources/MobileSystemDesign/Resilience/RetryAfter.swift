import Foundation

/// Reads the HTTP `Retry-After` header ([RFC 9110, section 10.2.3](https://www.rfc-editor.org/rfc/rfc9110#section-10.2.3)).
public enum RetryAfter {
    /// The longest wait ``parse(_:now:)`` returns: one day. A larger value would only keep a
    /// retry loop asleep; ``Retrier`` gives up on any wait above its policy's `maxDelay`.
    public static let maximum: Duration = .seconds(86_400)

    /// Headers longer than this are rejected without parsing.
    static let maximumLength = 64

    /// Parses a `Retry-After` value.
    ///
    /// The header holds either a number of seconds (`120`) or an HTTP date
    /// (`Wed, 21 Oct 2026 07:28:00 GMT`). The function accepts both, plus the two obsolete date
    /// formats RFC 9110 asks recipients to read.
    ///
    /// - Parameters:
    ///   - value: The header value.
    ///   - now: The current time, to turn a date into a wait.
    /// - Returns: The wait, between zero (a date in the past) and ``maximum``; `nil` when the
    ///   value is neither a non-negative integer nor a date.
    public static func parse(_ value: String, now: Date = Date()) -> Duration? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.utf8.count <= maximumLength else { return nil }

        if trimmed.utf8.allSatisfy({ $0 >= UInt8(ascii: "0") && $0 <= UInt8(ascii: "9") }) {
            let significant = trimmed.drop(while: { $0 == "0" })
            guard !significant.isEmpty else { return .zero }
            // `Int64(_:)` returns nil past 19 digits; such a value is above `maximum` anyway.
            guard let seconds = Int64(significant) else { return maximum }
            return min(.seconds(seconds), maximum)
        }

        guard let date = httpDate(trimmed) else { return nil }
        let interval = date.timeIntervalSince(now)
        return Duration.clampedSeconds(interval, limit: maximum)
    }

    private static func httpDate(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.isLenient = false
        for format in ["EEE, dd MMM yyyy HH:mm:ss 'GMT'", "EEEE, dd-MMM-yy HH:mm:ss 'GMT'", "EEE MMM d HH:mm:ss yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) { return date }
        }
        return nil
    }
}
