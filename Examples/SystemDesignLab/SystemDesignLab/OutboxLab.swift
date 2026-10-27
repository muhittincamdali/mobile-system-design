import MobileSystemDesign
import SwiftUI

@MainActor
@Observable
final class OutboxModel {
    private(set) var pending: [OutboxEntry<LikeChange>] = []
    private(set) var deadLetters: [OutboxEntry<LikeChange>] = []
    private(set) var likedPosts: Set<Int> = []
    private(set) var lastReport: OutboxFlushReport?
    private(set) var stats = LabServer.Stats()
    private(set) var storageError: String?
    var isOffline = true {
        didSet {
            let offline = isOffline
            Task {
                await server.setOffline(offline)
                if !offline { await flush() }
            }
        }
    }

    let posts = (0..<6).map(LabServer.post(at:))
    private let server: LabServer
    private let outbox: Outbox<LikeChange>?

    /// - Parameter storeURL: Where the outbox keeps unsent changes; `nil` keeps them in memory.
    init(server: LabServer, storeURL: URL?) {
        self.server = server
        let policy = RetryPolicy(maxAttempts: 8, initialDelay: .seconds(1), maxDelay: .seconds(60), jitter: .equal)
        do {
            if let storeURL {
                outbox = try Outbox(store: FileOutboxStore<LikeChange>(fileURL: storeURL), capacity: 200, retryPolicy: policy)
            } else {
                outbox = try Outbox(store: InMemoryOutboxStore<LikeChange>(), capacity: 200, retryPolicy: policy)
            }
        } catch {
            // A damaged file must not crash the app or be overwritten silently: run without an
            // outbox and say so.
            outbox = nil
            storageError = "The saved outbox could not be read."
        }
        Task {
            await server.setOffline(true)
            await self.refresh()
        }
    }

    func toggleLike(_ post: FeedPost) async {
        guard let outbox else { return }
        let liked = !likedPosts.contains(post.id)
        do {
            try await outbox.enqueue(LikeChange(postID: post.id, liked: liked), coalescingKey: "like-\(post.id)")
            if liked { likedPosts.insert(post.id) } else { likedPosts.remove(post.id) }
        } catch {
            storageError = "Could not save the change."
        }
        if !isOffline { await flush() }
        await refresh()
    }

    /// Sends what is waiting. The app calls it when the scene becomes active and when the
    /// network comes back.
    func flush() async {
        // A real app asks NWPathMonitor; sending while offline would only use up attempts.
        guard let outbox, !isOffline else { return }
        let server = self.server
        lastReport = await outbox.flush { entry in
            try await server.setLike(entry.payload, idempotencyKey: entry.id)
        }
        await refresh()
    }

    private func refresh() async {
        guard let outbox else { return }
        pending = await outbox.pending
        deadLetters = await outbox.deadLetters
        stats = await server.stats
    }
}

struct OutboxLabView: View {
    @State private var model: OutboxModel
    @State private var didSeed = false
    @Environment(\.scenePhase) private var scenePhase
    private let seeded: Bool

    init(server: LabServer, storeURL: URL?, seeded: Bool = false) {
        _model = State(initialValue: OutboxModel(server: server, storeURL: storeURL))
        self.seeded = seeded
    }

    var body: some View {
        List {
            Section {
                Toggle("Offline", isOn: $model.isOffline)
                LabeledContent("Waiting to send", value: "\(model.pending.count)")
                LabeledContent("Applied by the server", value: "\(model.stats.likesApplied)")
                LabeledContent("Duplicates ignored", value: "\(model.stats.duplicateLikesIgnored)")
                if let report = model.lastReport {
                    LabeledContent("Last flush", value: "\(report.delivered.count) sent, \(report.remaining) left")
                }
                if let storageError = model.storageError {
                    Label(storageError, systemImage: "externaldrive.badge.exclamationmark")
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("Outbox")
            } footer: {
                Text("Like posts while offline: each change is saved at once, and tapping twice replaces the waiting change. Go online and the outbox sends the changes in order, each with its idempotency key.")
            }

            Section("Posts") {
                ForEach(model.posts) { post in
                    Button {
                        Task { await model.toggleLike(post) }
                    } label: {
                        HStack {
                            PostRow(post: post)
                            Spacer()
                            Image(systemName: model.likedPosts.contains(post.id) ? "heart.fill" : "heart")
                                .foregroundStyle(.blue)
                                .accessibilityLabel(model.likedPosts.contains(post.id) ? "Liked" : "Not liked")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if !model.pending.isEmpty {
                Section("Queue, oldest first") {
                    ForEach(model.pending) { entry in
                        LabeledContent(
                            "\(entry.payload.liked ? "Like" : "Unlike") #\(entry.payload.postID)",
                            value: entry.attempts == 0 ? "waiting" : "\(entry.attempts) failed"
                        )
                    }
                }
            }
        }
        .navigationTitle("Offline likes")
        .task {
            guard seeded, !didSeed else { return }
            didSeed = true
            await model.seedForScreenshot()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await model.flush() } }
        }
    }
}

extension OutboxModel {
    /// Queues a few likes while offline, for the README screenshot.
    func seedForScreenshot() async {
        for post in posts.prefix(3) { await toggleLike(post) }
        await toggleLike(posts[1]) // the second tap replaces the waiting like
    }
}
