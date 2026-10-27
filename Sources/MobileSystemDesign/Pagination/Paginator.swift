import Foundation

/// One page of a cursor-paginated list, as an API returns it.
public struct Page<Item: Sendable, Cursor: Sendable & Hashable>: Sendable {
    /// The items on this page.
    public var items: [Item]
    /// The cursor of the next page, or `nil` on the last page.
    public var nextCursor: Cursor?

    /// Creates a page.
    public init(items: [Item], nextCursor: Cursor?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}

/// Loads a cursor-paginated list one page at a time, the way an infinite feed does.
///
/// The paginator takes care of the details that break feeds in practice:
///
/// - **One request at a time.** Calls to ``loadNextPage()`` while a page is loading wait for
///   that request instead of fetching the same page twice.
/// - **No duplicates.** Items whose `id` is already in the list are skipped; new posts at the
///   top of a feed shift offsets, and cursors do not always protect against it.
/// - **No endless loops.** A server that returns a cursor it already returned, or several pages
///   in a row with nothing new, ends the list instead of loading forever.
/// - **Bounded memory.** The list stops growing at `maxItems`.
/// - **Refresh wins.** ``refresh()`` discards a page that was still loading for the old list.
///
/// ```swift
/// let feed = Paginator<Post, String> { cursor in
///     try await api.posts(after: cursor)
/// }
/// let firstPage = try await feed.loadNextPage()
/// ```
public actor Paginator<Item: Identifiable & Sendable, Cursor: Sendable & Hashable> where Item.ID: Sendable {
    /// Why the list has no more pages.
    public enum EndReason: Sendable, Hashable {
        /// The server returned a page without a next cursor.
        case lastPage
        /// The list reached `maxItems`.
        case itemLimit
        /// The server returned a cursor it had returned before.
        case repeatedCursor
        /// The server returned `emptyPageLimit` pages in a row without new items.
        case noProgress
    }

    /// Where loading stands.
    public enum Phase: Sendable, Hashable {
        /// Ready to load the next page.
        case idle
        /// A page is loading.
        case loading
        /// No more pages will be loaded.
        case ended(EndReason)
        /// The last request failed; the next ``Paginator/loadNextPage()`` retries it.
        case failed
    }

    /// The items loaded so far, in server order.
    public private(set) var items: [Item] = []
    /// Where loading stands.
    public private(set) var phase: Phase = .idle

    /// The most items the list keeps.
    public nonisolated let maxItems: Int
    /// Pages in a row without a new item that end the list.
    public nonisolated let emptyPageLimit: Int

    private let fetch: @Sendable (Cursor?) async throws -> Page<Item, Cursor>
    private var nextCursor: Cursor?
    private var seenCursors: Set<Cursor> = []
    private var seenIDs: Set<Item.ID> = []
    private var emptyPagesInARow = 0
    private var inFlight: Task<[Item], any Error>?
    private var generation = 0

    /// Creates a paginator.
    ///
    /// - Parameters:
    ///   - maxItems: The most items to keep (at least 1). The default fits a long feed session.
    ///   - emptyPageLimit: Pages in a row without new items that end the list (at least 1).
    ///   - fetch: Loads the page after a cursor; `nil` asks for the first page.
    public init(
        maxItems: Int = 5_000,
        emptyPageLimit: Int = 3,
        fetch: @escaping @Sendable (Cursor?) async throws -> Page<Item, Cursor>
    ) {
        self.maxItems = max(1, maxItems)
        self.emptyPageLimit = max(1, emptyPageLimit)
        self.fetch = fetch
    }

    /// Whether more pages can be loaded.
    public var hasMore: Bool {
        if case .ended = phase { return false }
        return true
    }

    /// Loads the next page and appends its new items.
    ///
    /// - Returns: The items this call added; empty when the list has ended.
    /// - Throws: The fetch error. The paginator stays on the same cursor, so calling again
    ///   retries the page. `CancellationError` when ``refresh()`` replaced the list meanwhile.
    @discardableResult
    public func loadNextPage() async throws -> [Item] {
        if let inFlight { return try await inFlight.value }
        guard hasMore else { return [] }

        let cursor = nextCursor
        let requestGeneration = generation
        let fetch = self.fetch
        let task = Task<[Item], any Error> {
            let page = try await fetch(cursor)
            return try self.apply(page, generation: requestGeneration)
        }
        inFlight = task
        phase = .loading
        do {
            let added = try await task.value
            return added
        } catch {
            if requestGeneration == generation {
                inFlight = nil
                phase = .failed
            }
            throw error
        }
    }

    /// Clears the list and loads the first page again.
    ///
    /// A page that was loading for the old list is discarded.
    @discardableResult
    public func refresh() async throws -> [Item] {
        inFlight?.cancel()
        inFlight = nil
        generation &+= 1
        items = []
        phase = .idle
        nextCursor = nil
        seenCursors = []
        seenIDs = []
        emptyPagesInARow = 0
        return try await loadNextPage()
    }

    private func apply(_ page: Page<Item, Cursor>, generation requestGeneration: Int) throws -> [Item] {
        guard requestGeneration == generation else { throw CancellationError() }
        inFlight = nil

        var added: [Item] = []
        for item in page.items where items.count + added.count < maxItems {
            guard seenIDs.insert(item.id).inserted else { continue }
            added.append(item)
        }
        items.append(contentsOf: added)
        emptyPagesInARow = added.isEmpty ? emptyPagesInARow + 1 : 0

        if items.count >= maxItems {
            phase = .ended(.itemLimit)
        } else if let cursor = page.nextCursor {
            if !seenCursors.insert(cursor).inserted {
                phase = .ended(.repeatedCursor)
            } else if emptyPagesInARow >= emptyPageLimit {
                phase = .ended(.noProgress)
            } else {
                nextCursor = cursor
                phase = .idle
            }
        } else {
            phase = .ended(.lastPage)
        }
        return added
    }
}
