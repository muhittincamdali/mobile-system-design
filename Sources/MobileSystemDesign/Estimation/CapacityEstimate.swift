import Foundation

/// Back-of-the-envelope numbers for a mobile feature: request rate, bandwidth and storage.
///
/// System design interviews and design reviews start with these. The model is deliberately
/// simple, and every input is explicit:
///
/// ```swift
/// let feed = try CapacityEstimate(
///     dailyActiveUsers: 2_000_000,
///     requestsPerUserPerDay: 40,
///     averageResponseBytes: 30_000,
///     uploadsPerUserPerDay: 0.2,
///     averageUploadBytes: 1_500_000,
///     retentionDays: 365
/// )
/// feed.peakRequestsPerSecond   // ≈ 2 778 with the default peak factor of 3
/// ```
///
/// All arithmetic is in `Double`, so results stay finite for any valid input (no integer
/// overflow), and the initializer rejects inputs that are negative, NaN or infinite.
public struct CapacityEstimate: Sendable, Hashable {
    /// An input that cannot be used.
    public struct InvalidInput: Error, Sendable, Hashable {
        /// The name of the parameter.
        public let parameter: String
    }

    /// Seconds in a day.
    public static let secondsPerDay = 86_400.0

    /// Users who open the app on a given day.
    public let dailyActiveUsers: Double
    /// API requests one active user makes per day.
    public let requestsPerUserPerDay: Double
    /// The average response body size, in bytes.
    public let averageResponseBytes: Double
    /// Uploads (posts, photos, messages) one active user makes per day.
    public let uploadsPerUserPerDay: Double
    /// The average upload size, in bytes.
    public let averageUploadBytes: Double
    /// How many days uploads are kept.
    public let retentionDays: Double
    /// Peak traffic divided by average traffic. A factor of 2 to 5 is a common starting assumption.
    public let peakFactor: Double

    /// Creates an estimate.
    ///
    /// - Throws: ``InvalidInput`` naming the first parameter that is negative, NaN or
    ///   infinite, or a `peakFactor` below 1.
    public init(
        dailyActiveUsers: Double,
        requestsPerUserPerDay: Double,
        averageResponseBytes: Double,
        uploadsPerUserPerDay: Double = 0,
        averageUploadBytes: Double = 0,
        retentionDays: Double = 0,
        peakFactor: Double = 3
    ) throws {
        let inputs: [(String, Double)] = [
            ("dailyActiveUsers", dailyActiveUsers),
            ("requestsPerUserPerDay", requestsPerUserPerDay),
            ("averageResponseBytes", averageResponseBytes),
            ("uploadsPerUserPerDay", uploadsPerUserPerDay),
            ("averageUploadBytes", averageUploadBytes),
            ("retentionDays", retentionDays)
        ]
        for (name, value) in inputs where !(value.isFinite && value >= 0) {
            throw InvalidInput(parameter: name)
        }
        guard peakFactor.isFinite, peakFactor >= 1 else { throw InvalidInput(parameter: "peakFactor") }

        self.dailyActiveUsers = dailyActiveUsers
        self.requestsPerUserPerDay = requestsPerUserPerDay
        self.averageResponseBytes = averageResponseBytes
        self.uploadsPerUserPerDay = uploadsPerUserPerDay
        self.averageUploadBytes = averageUploadBytes
        self.retentionDays = retentionDays
        self.peakFactor = peakFactor
    }

    /// Requests per day across all users.
    public var requestsPerDay: Double { dailyActiveUsers * requestsPerUserPerDay }
    /// The average request rate.
    public var averageRequestsPerSecond: Double { requestsPerDay / Self.secondsPerDay }
    /// The request rate at peak.
    public var peakRequestsPerSecond: Double { averageRequestsPerSecond * peakFactor }
    /// Bytes the servers send per day.
    public var dailyEgressBytes: Double { requestsPerDay * averageResponseBytes }
    /// The bandwidth the servers send at peak, in bytes per second.
    public var peakEgressBytesPerSecond: Double { dailyEgressBytes / Self.secondsPerDay * peakFactor }
    /// Bytes uploaded per day.
    public var dailyIngressBytes: Double { dailyActiveUsers * uploadsPerUserPerDay * averageUploadBytes }
    /// Storage for the uploads over the retention period, before replication.
    public var storageBytes: Double { dailyIngressBytes * retentionDays }
    /// Bytes one user downloads per day: what the app costs them in mobile data.
    public var dailyBytesPerUser: Double { requestsPerUserPerDay * averageResponseBytes }
}

/// Client-side budgets: what fits in a phone's memory and on its data plan.
public enum ClientBudget {
    /// The memory a decoded bitmap takes: `width × height × bytesPerPixel`.
    ///
    /// A 12-megapixel photo is a few megabytes as a JPEG and about 48 MB decoded, which is why
    /// image pipelines downsample to the display size before caching.
    ///
    /// - Returns: The size in bytes, or `nil` when an input is negative or the product does
    ///   not fit in an `Int`.
    public static func decodedImageBytes(width: Int, height: Int, bytesPerPixel: Int = 4) -> Int? {
        guard width >= 0, height >= 0, bytesPerPixel >= 0 else { return nil }
        let (pixels, pixelOverflow) = width.multipliedReportingOverflow(by: height)
        guard !pixelOverflow else { return nil }
        let (bytes, byteOverflow) = pixels.multipliedReportingOverflow(by: bytesPerPixel)
        return byteOverflow ? nil : bytes
    }

    /// How many decoded images of the given size fit in `memoryBudget` bytes.
    ///
    /// - Returns: The count, `nil` for invalid sizes, or `Int.max` for zero-sized images.
    public static func imagesFitting(memoryBudget: Int, width: Int, height: Int, bytesPerPixel: Int = 4) -> Int? {
        guard memoryBudget >= 0, let size = decodedImageBytes(width: width, height: height, bytesPerPixel: bytesPerPixel) else {
            return nil
        }
        return size == 0 ? .max : memoryBudget / size
    }

    /// The pixel size of an image shown at `points` on a screen with `scale` pixels per point,
    /// rounded up. Download and decode at this size, not at the original size.
    ///
    /// - Returns: `nil` when `points` or `scale` is negative, NaN, infinite, or the result does
    ///   not fit in an `Int`.
    public static func pixelLength(points: Double, scale: Double) -> Int? {
        guard points.isFinite, scale.isFinite, points >= 0, scale >= 0 else { return nil }
        return Int(exactly: (points * scale).rounded(.up))
    }
}
