import MobileSystemDesign
import SwiftUI

/// Fetches feed pages through a retrier and a circuit breaker, and falls back to the last copy
/// of a page in an LRU cache when the server cannot answer.
actor FeedRepository {
    enum Source: Sendable, Equatable {
        case network
        case cache
    }

    private let server: LabServer
    private let breaker: CircuitBreaker
    private let retrier: Retrier
    private var pages = LRUCache<Int, Page<FeedPost, Int>>(countLimit: 20, timeToLive: 10 * 60)
    private(set) var lastSource: Source = .network

    init(server: LabServer, breaker: CircuitBreaker) {
        self.server = server
        self.breaker = breaker
        self.retrier = Retrier(policy: RetryPolicy(maxAttempts: 3, initialDelay: .milliseconds(300), maxDelay: .seconds(2)))
    }

    func page(after cursor: Int?) async throws -> Page<FeedPost, Int> {
        let key = cursor ?? 0
        do {
            let page = try await retrier.run { _ in
                try await breaker.run { try await server.feedPage(after: cursor) }
            }
            pages.insert(page, forKey: key, cost: page.items.count)
            lastSource = .network
            return page
        } catch {
            guard let cached = pages.value(forKey: key) else { throw error }
            lastSource = .cache
            return cached
        }
    }
}

@MainActor
@Observable
final class FeedModel {
    private(set) var posts: [FeedPost] = []
    private(set) var phase: Paginator<FeedPost, Int>.Phase = .idle
    private(set) var breakerState: CircuitBreaker.State = .closed(failures: 0)
    private(set) var stats = LabServer.Stats()
    private(set) var source: FeedRepository.Source = .network
    private(set) var lastError: String?
    var mode: LabServer.Mode = .healthy {
        didSet { Task { await server.setMode(mode) } }
    }

    let server: LabServer
    private let breaker = CircuitBreaker(configuration: .init(failureThreshold: 3, openDuration: .seconds(15)))
    private let repository: FeedRepository
    private let paginator: Paginator<FeedPost, Int>

    init(server: LabServer) {
        self.server = server
        let repository = FeedRepository(server: server, breaker: breaker)
        self.repository = repository
        self.paginator = Paginator(maxItems: 1_000) { cursor in
            try await repository.page(after: cursor)
        }
    }

    func loadMore() async {
        do {
            try await paginator.loadNextPage()
            lastError = nil
        } catch is CancellationError {
            return
        } catch {
            lastError = Self.describe(error)
        }
        await refreshState()
    }

    func refresh() async {
        do {
            try await paginator.refresh()
            lastError = nil
        } catch is CancellationError {
            return
        } catch {
            lastError = Self.describe(error)
        }
        await refreshState()
    }

    func resetBreaker() async {
        await breaker.reset()
        await refreshState()
    }

    private func refreshState() async {
        posts = await paginator.items
        phase = await paginator.phase
        breakerState = await breaker.state
        stats = await server.stats
        source = await repository.lastSource
    }

    static func describe(_ error: any Error) -> String {
        switch error {
        case CircuitBreakerError.open(let retryAfter):
            "Circuit open: failing fast for \(retryAfter.formatted(.units(allowed: [.seconds], width: .abbreviated)))"
        case let status as HTTPStatusError:
            "Server answered \(status.statusCode)"
        case let urlError as URLError:
            "Network error \(urlError.code.rawValue)"
        default:
            "Request failed"
        }
    }
}

struct FeedLabView: View {
    @State private var model: FeedModel

    init(server: LabServer) {
        _model = State(initialValue: FeedModel(server: server))
    }

    var body: some View {
        List {
            Section {
                Picker("Server", selection: $model.mode) {
                    ForEach(LabServer.Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                LabeledContent("Circuit breaker", value: model.breakerState.label)
                LabeledContent("Requests / failures", value: "\(model.stats.requests) / \(model.stats.failures)")
                LabeledContent("Last page from", value: model.source == .network ? "Network" : "Cache (fallback)")
                if let lastError = model.lastError {
                    Label(lastError, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("Retry · Circuit breaker · LRU fallback")
            } footer: {
                Text("Switch the server to Flaky or Down and pull to refresh. Retries hide single failures; three failed calls open the breaker; cached pages keep the feed readable.")
            }

            Section("Feed (\(model.posts.count) posts)") {
                ForEach(model.posts) { post in
                    PostRow(post: post)
                        .task {
                            if post.id == model.posts.last?.id { await model.loadMore() }
                        }
                }
                footer
            }
        }
        .navigationTitle("Feed")
        .refreshable { await model.refresh() }
        .task { if model.posts.isEmpty { await model.loadMore() } }
    }

    @ViewBuilder private var footer: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity)
        case .ended(let reason):
            Text(reason == .lastPage ? "You're all caught up" : "Stopped: \(String(describing: reason))")
                .foregroundStyle(.secondary)
        case .failed:
            Button("Retry") { Task { await model.loadMore() } }
        case .idle:
            EmptyView()
        }
    }
}

struct PostRow: View {
    let post: FeedPost

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(post.author.prefix(1)))
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(.blue.gradient))
            VStack(alignment: .leading, spacing: 4) {
                Text("\(post.author) · #\(post.id)").font(.subheadline.weight(.semibold))
                Text(post.text).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

extension CircuitBreaker.State {
    var label: String {
        switch self {
        case .closed(let failures): failures == 0 ? "Closed" : "Closed (\(failures) failed)"
        case .open: "Open"
        case .halfOpen: "Half-open"
        }
    }
}
