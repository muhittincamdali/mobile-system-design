import Foundation
import Testing
@testable import MobileSystemDesign

/// Runs the README samples (ReadmeExamples.swift, a symlink to the example app's
/// ReadmeSamples.swift), so the README shows code that works, not only code that compiles.
@Suite("README samples")
struct ReadmeSampleTests {
    @Test("quick start: the paginator walks the 100 items and stops")
    func quickStart() async throws {
        let feed = Paginator<FeedItem, Int> { cursor in try await loadPage(after: cursor) }
        var pages = 0
        while await feed.hasMore {
            try await feed.loadNextPage()
            pages += 1
        }
        #expect(pages == 5)
        #expect(await feed.items.map(\.id) == Array(0..<100))
        #expect(await feed.phase == .ended(.lastPage))
    }

    @Test("resilient request: a 503 is retried and the profile decodes")
    func resilientRequest() async throws {
        let url = try #require(URL(string: "https://api.example.com/profile"))
        StubProtocol.enqueue(status: 503, body: Data())
        StubProtocol.enqueue(status: 200, body: Data(#"{"name":"Ada"}"#.utf8))
        let profile = try await ReadmeSamples.fetchProfile(from: url, session: StubProtocol.session)
        #expect(profile.name == "Ada")
        #expect(StubProtocol.requestCount == 2)
    }

    @Test("offline outbox: likes are queued, coalesced and sent with their ids")
    func offlineOutbox() async throws {
        let outbox = try Outbox<ReadmeSamples.LikeChange>(store: InMemoryOutboxStore())
        try await ReadmeSamples.like(1, in: outbox)
        try await ReadmeSamples.like(1, in: outbox)
        try await ReadmeSamples.like(2, in: outbox)
        let ids = await outbox.pending.map(\.id)
        let received = Box<[UUID]>()
        received.value = []
        let report = await ReadmeSamples.sendPending(from: outbox) { _, key in
            received.value?.append(key)
        }
        #expect(report.delivered == ids)
        #expect(received.value == ids)
        #expect(ids.count == 2)
    }

    @Test("memory cache: stores, reads and trims")
    func memoryCache() async throws {
        let cache = ReadmeSamples.ThumbnailCache()
        let url = try #require(URL(string: "https://cdn.example.com/a.jpg"))
        await cache.store(Data(count: 30_000_000), for: url)
        #expect(await cache.image(for: url)?.count == 30_000_000)
        await cache.didReceiveMemoryWarning()
        #expect(await cache.image(for: url) == nil)
    }

    @Test("sync: the later edit wins although its device's clock is behind")
    func sync() throws {
        #expect(try ReadmeSamples.resolveConflict() == "Weekend groceries")
    }

    @Test("estimate: the numbers in the README comment")
    func estimate() throws {
        let estimate = try ReadmeSamples.estimateFeed()
        #expect(estimate.peakRequestsPerSecond.rounded() == 2_778)
        #expect(estimate.dailyEgressBytes == 2.4e12)
        #expect(estimate.storageBytes == 2.19e14)
    }
}

/// Answers requests from a queue of canned responses.
final class StubProtocol: URLProtocol, @unchecked Sendable {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var responses: [(Int, Data)] = []
    nonisolated(unsafe) private static var requests = 0

    static var requestCount: Int { lock.withLock { requests } }

    static func enqueue(status: Int, body: Data) {
        lock.withLock { responses.append((status, body)) }
    }

    static var session: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let next: (Int, Data)? = Self.lock.withLock {
            Self.requests += 1
            return Self.responses.isEmpty ? nil : Self.responses.removeFirst()
        }
        guard let (status, body) = next, let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
