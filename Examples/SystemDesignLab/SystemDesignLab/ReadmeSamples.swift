// The code samples of the README, kept here so they compile.
//
// Each sample sits between "// readme:begin <name>" and "// readme:end"; the README holds the
// same text, which `node scripts/check-readme-samples.mjs` verifies. The package's test target
// compiles this file through the symlink Tests/MobileSystemDesignTests/ReadmeExamples.swift
// and runs the samples in ReadmeSampleTests.swift.

import Foundation
import MobileSystemDesign
import SwiftUI

// readme:begin quick-start
struct FeedItem: Identifiable, Sendable {
    let id: Int
}

/// Stands in for your API: 100 items, 20 per page.
func loadPage(after cursor: Int?) async throws -> Page<FeedItem, Int> {
    let start = cursor ?? 0
    let end = min(start + 20, 100)
    let items = (start..<end).map { FeedItem(id: $0) }
    return Page(items: items, nextCursor: end < 100 ? end : nil)
}

struct ContentView: View {
    @State private var items: [FeedItem] = []
    private let feed = Paginator<FeedItem, Int> { cursor in
        try await loadPage(after: cursor)
    }

    var body: some View {
        List(items) { item in
            Text("Item \(item.id)")
                .task {
                    if item.id == items.last?.id { await loadMore() }
                }
        }
        .task { await loadMore() }
    }

    private func loadMore() async {
        if let page = try? await feed.loadNextPage() {
            items += page
        }
    }
}
// readme:end

enum ReadmeSamples {
    struct Profile: Decodable, Sendable {
        let name: String
    }

    // readme:begin resilient-request
    static let retrier = Retrier(policy: RetryPolicy(maxAttempts: 3, initialDelay: .milliseconds(200)))
    static let breaker = CircuitBreaker(configuration: .init(failureThreshold: 5, openDuration: .seconds(30)))

    static func fetchProfile(from url: URL, session: URLSession = .shared) async throws -> Profile {
        try await retrier.run { _ in
            try await breaker.run {
                let (data, response) = try await session.data(from: url)
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    throw HTTPStatusError(response: http) // 429 and 5xx are retried
                }
                return try JSONDecoder().decode(Profile.self, from: data)
            }
        }
    }
    // readme:end

    // readme:begin offline-outbox
    struct LikeChange: Codable, Sendable {
        let postID: Int
        let liked: Bool
    }

    static func makeOutbox() throws -> Outbox<LikeChange> {
        let folder = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let store = FileOutboxStore<LikeChange>(fileURL: folder.appendingPathComponent("outbox.json"))
        return try Outbox(store: store)
    }

    static func like(_ postID: Int, in outbox: Outbox<LikeChange>) async throws {
        // Saved before this returns; a second tap replaces the waiting change.
        try await outbox.enqueue(LikeChange(postID: postID, liked: true), coalescingKey: "like-\(postID)")
    }

    // Call when the network is back or the scene becomes active.
    static func sendPending(
        from outbox: Outbox<LikeChange>,
        using send: @escaping @Sendable (LikeChange, UUID) async throws -> Void
    ) async -> OutboxFlushReport {
        await outbox.flush { entry in
            try await send(entry.payload, entry.id) // entry.id is the idempotency key
        }
    }
    // readme:end

    // readme:begin memory-cache
    actor ThumbnailCache {
        // At most 200 images and 50 MB; entries expire after 10 minutes.
        private var cache = LRUCache<URL, Data>(countLimit: 200, costLimit: 50_000_000, timeToLive: 600)

        func image(for url: URL) -> Data? {
            cache.value(forKey: url)
        }

        func store(_ data: Data, for url: URL) {
            cache.insert(data, forKey: url, cost: data.count)
        }

        func didReceiveMemoryWarning() {
            cache.trim(toCost: cache.costLimit / 2)
        }
    }
    // readme:end

    // readme:begin sync
    static func resolveConflict() throws -> String {
        var phone = HybridLogicalClock(node: "phone")
        var tablet = HybridLogicalClock(node: "tablet")
        let now = Date()

        var phoneTitle = LWWRegister("Groceries", timestamp: try phone.tick(physicalTime: now))
        // The tablet's clock is 30 seconds behind, but its edit happens later.
        _ = try tablet.receive(phoneTitle.timestamp, physicalTime: now.addingTimeInterval(-30))
        let tabletTitle = LWWRegister("Weekend groceries", timestamp: try tablet.tick(physicalTime: now.addingTimeInterval(-29)))

        phoneTitle.merge(tabletTitle)
        return phoneTitle.value // "Weekend groceries"
    }
    // readme:end

    // readme:begin estimate
    static func estimateFeed() throws -> CapacityEstimate {
        try CapacityEstimate(
            dailyActiveUsers: 2_000_000,
            requestsPerUserPerDay: 40,
            averageResponseBytes: 30_000,
            uploadsPerUserPerDay: 0.2,
            averageUploadBytes: 1_500_000,
            retentionDays: 365
        )
        // peakRequestsPerSecond ≈ 2,778 · dailyEgressBytes = 2.4 TB · storageBytes = 219 TB
    }
    // readme:end
}
