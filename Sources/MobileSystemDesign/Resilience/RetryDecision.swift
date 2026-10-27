import Foundation

/// What to do after an attempt failed.
public enum RetryDecision: Sendable, Hashable {
    /// Try again after the policy's backoff delay.
    case retry
    /// Try again after the delay the server asked for (`Retry-After`).
    case retryAfter(Duration)
    /// Give up and return the error to the caller.
    case doNotRetry

    /// The default classification for networking errors.
    ///
    /// - Cancellation never retries.
    /// - ``HTTPStatusError`` retries 408, 429, 500, 502, 503 and 504, honouring its
    ///   `retryAfter`. Other client errors (4xx) are permanent: sending the same request again
    ///   gets the same answer.
    /// - `URLError` retries the codes that describe a temporary connection problem, such as
    ///   `.timedOut`, `.networkConnectionLost` and `.notConnectedToInternet`.
    /// - Every other error does not retry.
    ///
    /// Only retry requests that are safe to repeat: `GET`, `PUT`, `DELETE`, or a `POST` that
    /// carries an idempotency key the server deduplicates.
    public static func classify(_ error: any Error) -> RetryDecision {
        if error is CancellationError { return .doNotRetry }
        if let status = error as? HTTPStatusError {
            guard HTTPStatusError.retryableStatusCodes.contains(status.statusCode) else { return .doNotRetry }
            if let retryAfter = status.retryAfter { return .retryAfter(retryAfter) }
            return .retry
        }
        if let urlError = error as? URLError {
            return transientURLErrorCodes.contains(urlError.code) ? .retry : .doNotRetry
        }
        return .doNotRetry
    }

    private static let transientURLErrorCodes: Set<URLError.Code> = [
        .timedOut,
        .networkConnectionLost,
        .notConnectedToInternet,
        .cannotConnectToHost,
        .cannotFindHost,
        .dnsLookupFailed,
        .internationalRoamingOff,
        .callIsActive,
        .dataNotAllowed
    ]
}

/// An HTTP response with a status code that is not a success.
public struct HTTPStatusError: Error, Sendable, Hashable {
    /// The status codes ``RetryDecision/classify(_:)`` retries.
    public static let retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]

    /// The HTTP status code.
    public let statusCode: Int
    /// The wait the server asked for in its `Retry-After` header, if any.
    public let retryAfter: Duration?

    /// Creates an error.
    public init(statusCode: Int, retryAfter: Duration? = nil) {
        self.statusCode = statusCode
        self.retryAfter = retryAfter
    }

    /// Creates an error from a response, reading its `Retry-After` header.
    public init(response: HTTPURLResponse, now: Date = Date()) {
        let header = response.value(forHTTPHeaderField: "Retry-After")
        self.init(statusCode: response.statusCode, retryAfter: header.flatMap { RetryAfter.parse($0, now: now) })
    }
}
