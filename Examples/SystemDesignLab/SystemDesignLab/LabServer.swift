import Foundation
import MobileSystemDesign

/// A post in the lab's feed.
struct FeedPost: Identifiable, Sendable, Hashable, Codable {
    let id: Int
    let author: String
    let text: String
}

/// A like or unlike the user made, waiting in the outbox.
struct LikeChange: Codable, Sendable, Hashable {
    let postID: Int
    let liked: Bool
}

/// An in-process stand-in for the backend, so the lab runs without a network and every run is
/// the same. It answers like a real API would: pages with cursors, 503 with `Retry-After` while
/// it is "down", and `notConnectedToInternet` while the device is "offline".
actor LabServer {
    enum Mode: String, CaseIterable, Sendable, Identifiable {
        case healthy = "Healthy"
        case flaky = "Flaky"
        case down = "Down"
        var id: Self { self }
    }

    struct Stats: Sendable, Equatable {
        var requests = 0
        var failures = 0
        var likesApplied = 0
        var duplicateLikesIgnored = 0
    }

    static let pageSize = 20
    static let postCount = 200

    private(set) var stats = Stats()
    private var mode: Mode = .healthy
    private var isOffline = false
    private var latency: Duration
    private var appliedLikeKeys: Set<UUID> = []
    private var likes: [Int: Bool] = [:]
    private var random = SeededGenerator(seed: 7)

    init(latency: Duration = .milliseconds(250)) {
        self.latency = latency
    }

    func setMode(_ mode: Mode) { self.mode = mode }
    func setOffline(_ offline: Bool) { isOffline = offline }
    func setLatency(_ latency: Duration) { self.latency = latency }
    func isLiked(_ postID: Int) -> Bool { likes[postID] ?? false }

    /// `GET /feed?after=<cursor>`
    func feedPage(after cursor: Int?) async throws -> Page<FeedPost, Int> {
        try await respond()
        let start = cursor ?? 0
        let end = min(start + Self.pageSize, Self.postCount)
        let posts = (start..<end).map(Self.post(at:))
        return Page(items: posts, nextCursor: end < Self.postCount ? end : nil)
    }

    /// `PUT /posts/<id>/like` with an `Idempotency-Key` header.
    func setLike(_ change: LikeChange, idempotencyKey: UUID) async throws {
        try await respond()
        guard appliedLikeKeys.insert(idempotencyKey).inserted else {
            stats.duplicateLikesIgnored += 1
            return
        }
        likes[change.postID] = change.liked
        stats.likesApplied += 1
    }

    private func respond() async throws {
        stats.requests += 1
        if isOffline {
            stats.failures += 1
            throw URLError(.notConnectedToInternet)
        }
        try await Task.sleep(for: latency)
        switch mode {
        case .healthy:
            return
        case .flaky where Double(random.next() % 100) < 40:
            stats.failures += 1
            throw HTTPStatusError(statusCode: 503)
        case .flaky:
            return
        case .down:
            stats.failures += 1
            throw HTTPStatusError(statusCode: 503, retryAfter: .seconds(30))
        }
    }

    private static let authors = ["Ada", "Grace", "Linus", "Margaret", "Ken", "Barbara", "Dennis", "Radia"]
    private static let topics = [
        "Shipped offline mode: the outbox drained 14 likes on reconnect.",
        "Cursor pagination beat offset pagination when new posts arrived mid-scroll.",
        "Downsampled thumbnails to the cell size; memory use dropped a lot.",
        "Circuit breaker opened during the outage and the app stayed responsive.",
        "Hybrid logical clocks fixed our conflicts from phones with wrong clocks.",
        "Prefetching two pages ahead hides the network on fast scrolls."
    ]

    static func post(at index: Int) -> FeedPost {
        FeedPost(
            id: index + 1,
            author: authors[index % authors.count],
            text: topics[(index * 5) % topics.count]
        )
    }
}

/// A deterministic random number generator (SplitMix64), so lab runs and screenshots repeat.
struct SeededGenerator: RandomNumberGenerator, Sendable {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
