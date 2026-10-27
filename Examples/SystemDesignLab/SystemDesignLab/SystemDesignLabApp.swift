import MobileSystemDesign
import SwiftUI

@main
struct SystemDesignLabApp: App {
    var body: some Scene {
        WindowGroup {
            LabRootView(launchLab: LaunchOptions.lab)
        }
    }
}

/// The labs, one per building block of the guide.
enum Lab: String, CaseIterable, Identifiable, Hashable {
    case feed, outbox, sync, estimator

    var id: Self { self }

    var title: String {
        switch self {
        case .feed: "Feed: retries, breaker, cache"
        case .outbox: "Offline likes: outbox"
        case .sync: "Sync: clocks and conflicts"
        case .estimator: "Capacity estimator"
        }
    }

    var systemImage: String {
        switch self {
        case .feed: "list.bullet.rectangle"
        case .outbox: "tray.and.arrow.up"
        case .sync: "arrow.triangle.2.circlepath"
        case .estimator: "function"
        }
    }
}

/// `-lab <name>` opens a lab directly, with the state shown in the README screenshots.
enum LaunchOptions {
    static var lab: Lab? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-lab"), arguments.indices.contains(index + 1) else { return nil }
        return Lab(rawValue: arguments[index + 1])
    }
}

struct LabRootView: View {
    let launchLab: Lab?
    @State private var path: [Lab] = []
    private let server = LabServer()

    var body: some View {
        NavigationStack(path: $path) {
            List(Lab.allCases) { lab in
                NavigationLink(value: lab) {
                    Label(lab.title, systemImage: lab.systemImage)
                }
            }
            .navigationTitle("System Design Lab")
            .navigationDestination(for: Lab.self) { lab in
                destination(for: lab)
            }
        }
        .tint(.blue)
        .onAppear {
            if let launchLab, path.isEmpty { path = [launchLab] }
        }
    }

    @ViewBuilder private func destination(for lab: Lab) -> some View {
        switch lab {
        case .feed:
            FeedLabView(server: server)
        case .outbox:
            OutboxLabView(server: server, storeURL: launchLab == nil ? Self.outboxURL : nil, seeded: launchLab == .outbox)
        case .sync:
            SyncLabView(seeded: launchLab == .sync)
        case .estimator:
            EstimatorLabView()
        }
    }

    private static var outboxURL: URL? {
        try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("SystemDesignLab/outbox.json")
    }
}
