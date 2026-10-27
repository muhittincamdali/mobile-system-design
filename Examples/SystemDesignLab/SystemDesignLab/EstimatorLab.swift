import MobileSystemDesign
import SwiftUI

struct EstimatorLabView: View {
    @State private var dailyActiveUsers = 2_000_000.0
    @State private var requestsPerUser = 40.0
    @State private var responseKilobytes = 30.0
    @State private var uploadsPerUser = 0.2
    @State private var uploadMegabytes = 1.5
    @State private var retentionDays = 365.0
    @State private var peakFactor = 3.0

    private var estimate: Result<CapacityEstimate, any Error> {
        Result {
            try CapacityEstimate(
                dailyActiveUsers: dailyActiveUsers,
                requestsPerUserPerDay: requestsPerUser,
                averageResponseBytes: responseKilobytes * 1_000,
                uploadsPerUserPerDay: uploadsPerUser,
                averageUploadBytes: uploadMegabytes * 1_000_000,
                retentionDays: retentionDays,
                peakFactor: peakFactor
            )
        }
    }

    var body: some View {
        Form {
            Section("Inputs") {
                number("Daily active users", value: $dailyActiveUsers)
                number("Requests per user per day", value: $requestsPerUser)
                number("Response size (kB)", value: $responseKilobytes)
                number("Uploads per user per day", value: $uploadsPerUser)
                number("Upload size (MB)", value: $uploadMegabytes)
                number("Retention (days)", value: $retentionDays)
                number("Peak factor", value: $peakFactor)
            }
            switch estimate {
            case .success(let estimate):
                Section("Server") {
                    LabeledContent("Average requests/s", value: Formatting.rate(estimate.averageRequestsPerSecond))
                    LabeledContent("Peak requests/s", value: Formatting.rate(estimate.peakRequestsPerSecond))
                    LabeledContent("Peak egress", value: Formatting.bytes(estimate.peakEgressBytesPerSecond) + "/s")
                    LabeledContent("Uploads per day", value: Formatting.bytes(estimate.dailyIngressBytes))
                    LabeledContent("Storage for retention", value: Formatting.bytes(estimate.storageBytes))
                }
                Section("Phone") {
                    LabeledContent("Data per user per day", value: Formatting.bytes(estimate.dailyBytesPerUser))
                    LabeledContent("12 MP photo, decoded", value: Formatting.bytes(ClientBudget.decodedImageBytes(width: 4_000, height: 3_000).map(Double.init)))
                    LabeledContent("Same photo at 390 pt × 3", value: Formatting.bytes(thumbnailBytes))
                }
            case .failure(let error):
                Section {
                    let parameter = (error as? CapacityEstimate.InvalidInput)?.parameter ?? "the inputs"
                    Label("Check \(parameter): it must be a finite, non-negative number.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Estimator")
    }

    private var thumbnailBytes: Double? {
        guard let side = ClientBudget.pixelLength(points: 390, scale: 3),
              let bytes = ClientBudget.decodedImageBytes(width: side, height: side * 3 / 4)
        else { return nil }
        return Double(bytes)
    }

    private func number(_ title: String, value: Binding<Double>) -> some View {
        LabeledContent(title) {
            TextField(title, value: value, format: .number)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 130)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
        }
    }
}

enum Formatting {
    /// Formats a byte count. Values that do not fit in `Int64` (or are NaN) are shown as such
    /// instead of trapping in the integer conversion.
    static func bytes(_ value: Double?) -> String {
        guard let value, value.isFinite, value >= 0 else { return "—" }
        guard value < 9.0e18 else { return "more than 9 EB" }
        return Int64(value.rounded()).formatted(.byteCount(style: .decimal))
    }

    static func rate(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        return value.formatted(.number.precision(.fractionLength(0...1)))
    }
}
