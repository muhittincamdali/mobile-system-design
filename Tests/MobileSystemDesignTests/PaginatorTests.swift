import Foundation
import Testing
@testable import MobileSystemDesign

struct Post: Identifiable, Sendable, Hashable {
    let id: Int
}

/// A scripted server: returns the queued responses in order and records the cursors it got.
actor ScriptedFeed {
    private var responses: [Result<Page<Post, Int>, any Error>]
    private(set) var requestedCursors: [Int?] = []
    private var gate: CheckedContinuation<Void, Never>?
    private var holdNext = false

    init(_ responses: [Result<Page<Post, Int>, any Error>]) {
        self.responses = responses
    }

    func holdNextResponse() { holdNext = true }

    func release() {
        gate?.resume()
        gate = nil
    }

    var isHolding: Bool { gate != nil }

    func fetch(_ cursor: Int?) async throws -> Page<Post, Int> {
        requestedCursors.append(cursor)
        if holdNext {
            holdNext = false
            await withCheckedContinuation { gate = $0 }
        }
        guard !responses.isEmpty else { return Page(items: [], nextCursor: nil) }
        return try responses.removeFirst().get()
    }
}

func page(_ ids: ClosedRange<Int>, next: Int?) -> Result<Page<Post, Int>, any Error> {
    .success(Page(items: ids.map(Post.init), nextCursor: next))
}

@Suite("Paginator")
struct PaginatorTests {
    @Test("loads pages in order and ends on the last page")
    func loadsUntilLastPage() async throws {
        let server = ScriptedFeed([page(1...3, next: 10), page(4...5, next: nil)])
        let feed = Paginator<Post, Int> { try await server.fetch($0) }

        #expect(try await feed.loadNextPage().map(\.id) == [1, 2, 3])
        #expect(try await feed.loadNextPage().map(\.id) == [4, 5])
        #expect(await feed.phase == .ended(.lastPage))
        #expect(try await feed.loadNextPage().isEmpty)
        #expect(await server.requestedCursors == [nil, 10])
        #expect(await feed.items.map(\.id) == [1, 2, 3, 4, 5])
    }

    @Test("skips items that are already in the list")
    func deduplicates() async throws {
        let server = ScriptedFeed([page(1...3, next: 1), page(3...5, next: nil)])
        let feed = Paginator<Post, Int> { try await server.fetch($0) }
        try await feed.loadNextPage()
        #expect(try await feed.loadNextPage().map(\.id) == [4, 5])
        #expect(await feed.items.map(\.id) == [1, 2, 3, 4, 5])
    }

    @Test("a repeated cursor ends the list instead of looping")
    func repeatedCursor() async throws {
        let server = ScriptedFeed([page(1...2, next: 7), page(3...4, next: 7), page(5...6, next: 8)])
        let feed = Paginator<Post, Int> { try await server.fetch($0) }
        try await feed.loadNextPage()
        try await feed.loadNextPage()
        #expect(await feed.phase == .ended(.repeatedCursor))
        #expect(await feed.items.count == 4)
        #expect(await server.requestedCursors.count == 2)
    }

    @Test("pages without new items end the list after the limit")
    func noProgress() async throws {
        let server = ScriptedFeed([page(1...2, next: 1), page(1...2, next: 2), .success(Page(items: [], nextCursor: 3))])
        let feed = Paginator<Post, Int>(emptyPageLimit: 2) { try await server.fetch($0) }
        try await feed.loadNextPage()
        try await feed.loadNextPage()
        #expect(await feed.phase == .idle)
        try await feed.loadNextPage()
        #expect(await feed.phase == .ended(.noProgress))
    }

    @Test("stops growing at maxItems")
    func itemLimit() async throws {
        let server = ScriptedFeed([page(1...4, next: 1), page(5...8, next: 2)])
        let feed = Paginator<Post, Int>(maxItems: 6) { try await server.fetch($0) }
        try await feed.loadNextPage()
        #expect(try await feed.loadNextPage().map(\.id) == [5, 6])
        #expect(await feed.phase == .ended(.itemLimit))
        #expect(await feed.hasMore == false)
    }

    @Test("a failed page is retried with the same cursor")
    func retriesFailedPage() async throws {
        let server = ScriptedFeed([page(1...2, next: 5), .failure(URLError(.timedOut)), page(3...4, next: nil)])
        let feed = Paginator<Post, Int> { try await server.fetch($0) }
        try await feed.loadNextPage()
        await #expect(throws: URLError.self) { try await feed.loadNextPage() }
        #expect(await feed.phase == .failed)
        #expect(try await feed.loadNextPage().map(\.id) == [3, 4])
        #expect(await server.requestedCursors == [nil, 5, 5])
    }

    @Test("concurrent calls share one request")
    func coalescesConcurrentLoads() async throws {
        let server = ScriptedFeed([page(1...3, next: 9), page(4...6, next: nil)])
        let feed = Paginator<Post, Int> { try await server.fetch($0) }
        await server.holdNextResponse()

        async let first = feed.loadNextPage()
        while await !server.isHolding { await Task.yield() }
        async let second = feed.loadNextPage()
        while await feed.phase != .loading { await Task.yield() }
        try await Task.sleep(for: .milliseconds(100)) // let the second call reach the paginator
        await server.release()

        let (a, b) = try await (first, second)
        #expect(a.map(\.id) == [1, 2, 3])
        #expect(b.map(\.id) == [1, 2, 3])
        #expect(await server.requestedCursors == [nil])
    }

    @Test("refresh discards a page that was loading for the old list")
    func refreshDiscardsStalePage() async throws {
        let server = ScriptedFeed([page(1...2, next: 3), page(10...11, next: nil), page(20...21, next: nil)])
        let feed = Paginator<Post, Int> { try await server.fetch($0) }
        try await feed.loadNextPage()

        await server.holdNextResponse()
        let stale = Task { try await feed.loadNextPage() }
        while await !server.isHolding { await Task.yield() }

        let refreshTask = Task { try await feed.refresh() }
        while await server.requestedCursors.count < 3 { await Task.yield() }
        await server.release()

        await #expect(throws: CancellationError.self) { try await stale.value }
        let refreshed = try await refreshTask.value
        #expect(await feed.items.map(\.id) == refreshed.map(\.id))
        #expect(await server.requestedCursors == [nil, 3, nil])
        #expect(await feed.phase == .ended(.lastPage))
    }

    @Test("limits below 1 are raised to 1")
    func clampsLimits() async {
        let feed = Paginator<Post, Int>(maxItems: -10, emptyPageLimit: 0) { _ in Page(items: [], nextCursor: nil) }
        #expect(feed.maxItems == 1)
        #expect(feed.emptyPageLimit == 1)
    }
}
