import Foundation
import Testing
@testable import MobileSystemDesign

@Suite("CapacityEstimate")
struct CapacityEstimateTests {
    @Test("computes rates, bandwidth and storage")
    func numbers() throws {
        let estimate = try CapacityEstimate(
            dailyActiveUsers: 2_000_000,
            requestsPerUserPerDay: 40,
            averageResponseBytes: 30_000,
            uploadsPerUserPerDay: 0.2,
            averageUploadBytes: 1_500_000,
            retentionDays: 365
        )
        #expect(estimate.requestsPerDay == 80_000_000)
        #expect(abs(estimate.averageRequestsPerSecond - 925.926) < 0.001)
        #expect(abs(estimate.peakRequestsPerSecond - 2_777.778) < 0.001)
        #expect(estimate.dailyEgressBytes == 2.4e12)
        #expect(estimate.dailyIngressBytes == 6e11)
        #expect(estimate.storageBytes == 2.19e14)
        #expect(estimate.dailyBytesPerUser == 1_200_000)
        #expect(abs(estimate.peakEgressBytesPerSecond - 2.4e12 / 86_400 * 3) < 1)
    }

    @Test("rejects inputs that are negative, NaN or infinite", arguments: [-1, Double.nan, .infinity, -.infinity])
    func rejectsInvalid(value: Double) {
        #expect(throws: CapacityEstimate.InvalidInput(parameter: "dailyActiveUsers")) {
            try CapacityEstimate(dailyActiveUsers: value, requestsPerUserPerDay: 1, averageResponseBytes: 1)
        }
        #expect(throws: CapacityEstimate.InvalidInput(parameter: "retentionDays")) {
            try CapacityEstimate(dailyActiveUsers: 1, requestsPerUserPerDay: 1, averageResponseBytes: 1, retentionDays: value)
        }
    }

    @Test("rejects a peak factor below 1", arguments: [0.5, 0, Double.nan, .infinity])
    func rejectsPeakFactor(value: Double) {
        #expect(throws: CapacityEstimate.InvalidInput(parameter: "peakFactor")) {
            try CapacityEstimate(dailyActiveUsers: 1, requestsPerUserPerDay: 1, averageResponseBytes: 1, peakFactor: value)
        }
    }

    @Test("very large inputs stay finite or become infinity, never trap")
    func largeInputs() throws {
        let estimate = try CapacityEstimate(dailyActiveUsers: 1e200, requestsPerUserPerDay: 1e200, averageResponseBytes: 1e200)
        #expect(estimate.dailyEgressBytes == .infinity)
        #expect(!estimate.averageRequestsPerSecond.isNaN)
    }
}

@Suite("ClientBudget")
struct ClientBudgetTests {
    @Test("a 12-megapixel photo takes 48 MB decoded")
    func decodedPhoto() {
        #expect(ClientBudget.decodedImageBytes(width: 4_000, height: 3_000) == 48_000_000)
        #expect(ClientBudget.imagesFitting(memoryBudget: 100_000_000, width: 4_000, height: 3_000) == 2)
        // Downsampled to a 390-point-wide cell on a 3× screen:
        let side = ClientBudget.pixelLength(points: 390, scale: 3)
        #expect(side == 1_170)
        #expect(ClientBudget.decodedImageBytes(width: 1_170, height: 1_170) == 5_475_600)
    }

    @Test("overflowing or negative sizes return nil instead of trapping")
    func overflow() {
        #expect(ClientBudget.decodedImageBytes(width: .max, height: 2) == nil)
        #expect(ClientBudget.decodedImageBytes(width: 1 << 31, height: 1 << 31, bytesPerPixel: 4) == nil)
        #expect(ClientBudget.decodedImageBytes(width: -1, height: 10) == nil)
        #expect(ClientBudget.imagesFitting(memoryBudget: -1, width: 1, height: 1) == nil)
        #expect(ClientBudget.imagesFitting(memoryBudget: 10, width: 0, height: 10) == .max)
    }

    @Test("pixel lengths reject values that do not fit in an Int", arguments: [Double.nan, .infinity, -1, 1e300])
    func pixelLengthInvalid(points: Double) {
        #expect(ClientBudget.pixelLength(points: points, scale: 2) == nil)
    }

    @Test("pixel lengths round up")
    func pixelLengthRounding() {
        #expect(ClientBudget.pixelLength(points: 10.1, scale: 2) == 21)
        #expect(ClientBudget.pixelLength(points: 0, scale: 3) == 0)
    }
}
