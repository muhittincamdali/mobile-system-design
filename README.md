<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

A guide to designing the client side of mobile apps — feeds, chat, live tracking, offline
media — together with a Swift package that implements its building blocks. It is for
engineers preparing for mobile system design interviews and for teams writing design
documents. The guide explains each design question; the package gives the answer as small,
dependency-free Swift types with tests, so you can read the code behind every recommendation,
run it in the example app, and use it in your own.

## Highlights

- **A framework and four case studies** — a six-step structure for a 45–60 minute session,
  applied to a photo feed, a chat app, live ride tracking and offline music downloads.
- **Building blocks you can run** — LRU cache, retry with backoff and `Retry-After`, circuit
  breaker, token bucket, cursor paginator, persistent outbox, hybrid logical clock and
  last-writer-wins register, capacity estimates.
- **Built for bad input** — values from remote configuration, server headers and stored files
  are clamped or rejected: no trap on NaN, overflow or a malformed header, no endless loop on
  a server that repeats its cursor, and every queue and cache has a size limit.
- **Swift 6 language mode** — actors for shared state, `Sendable` types, no warnings.
- **Tested** — 109 Swift Testing tests, run on macOS and an iPhone simulator, including the
  README samples below.
- **An example app** — [SystemDesignLab](Examples/SystemDesignLab) runs each building block
  against a simulated server that you can make flaky, take down or disconnect.

### What's included

| Area            | Types                                                                                                       | Guide page                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Caching         | `LRUCache`                                                                                                  | [Caching and image loading](docs/topics/caching-and-images.md)                      |
| Resilience      | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [Network resilience and real-time updates](docs/topics/resilience-and-real-time.md) |
| Pagination      | `Paginator`, `Page`                                                                                         | [API design and pagination](docs/topics/api-and-pagination.md)                      |
| Offline changes | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`                                                          | [Offline support and sync](docs/topics/offline-and-sync.md)                         |
| Sync            | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`                                                      | [Offline support and sync](docs/topics/offline-and-sync.md#conflicts)               |
| Estimation      | `CapacityEstimate`, `ClientBudget`                                                                          | [A framework for mobile system design](docs/framework.md#2-estimate)                |

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Paste it into the search field at the top right of the window. Leave **Dependency Rule** at
**Up to Next Major Version** from `2.0.0`, then click **Add Package**. In the next window,
choose your app target next to **MobileSystemDesign** and click **Add Package** again.

**2. Import the module**

```swift
import MobileSystemDesign
```

Put this line at the top of the Swift file where you use the package.

**3. Use it**

In a new Xcode app (**File › New › Project… › App**), replace everything in `ContentView.swift`
with:

<!-- sample: quick-start -->

```swift
import MobileSystemDesign
import SwiftUI

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
```

Press **Run** (⌘R). The app shows a list that loads 20 more rows each time you scroll to the
end, and stops after row 99. Replace `loadPage(after:)` with your API call.

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/mobile-system-design.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "MobileSystemDesign", package: "mobile-system-design")
    ])
]
```

## Usage

The samples below are copied from
[`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift).
The example app compiles that file, the test suite compiles and runs it, and
`node scripts/check-readme-samples.mjs` checks that this README shows the same code.

### Retry a request and stop calling a failing server

Temporary failures (timeouts, lost connections, `429`, `503`) are retried with exponential
backoff and jitter; five failures in a row open the circuit breaker, and calls then fail at
once for 30 seconds instead of waiting for timeouts.

<!-- sample: resilient-request -->

```swift
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
```

### Keep changes made offline until they are sent

Each change is saved to a file before `enqueue` returns, sent oldest first when you flush,
and carries a UUID to use as the request's idempotency key.

<!-- sample: offline-outbox -->

```swift
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
```

### Cache images in memory

<!-- sample: memory-cache -->

```swift
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
```

### Resolve an edit made on two devices

A hybrid logical clock orders an edit after everything its device has seen, so the later
edit wins even when that device's clock is behind.

<!-- sample: sync -->

```swift
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
```

### Estimate the load of a feature

<!-- sample: estimate -->

```swift
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
```

## Example app

[SystemDesignLab](Examples/SystemDesignLab) has one lab per building block. Its server runs
in the app, so the labs work without a backend and look the same on every run.

| Feed                                                                                                                                                                                                                                                         | Offline likes                                                                                                                                                                                                                                                  | Sync                                                                                                                                                                                                                                                           | Estimator                                                                                                                                                                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="Feed lab: server mode picker, circuit breaker state, request counts and the loaded posts" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="Offline likes lab: offline switch, three changes waiting in the outbox and liked posts" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="Sync lab: phone and tablet titles with hybrid timestamps after the tablet's later edit won" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="Estimator lab: usage inputs and the resulting request rates, bandwidth and storage" width="200"></picture> |

Open `Examples/SystemDesignLab/SystemDesignLab.xcodeproj`, choose an iPhone simulator or
**My Mac**, and press **Run**. The screenshots are taken by
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) from the running app.

## Documentation

The [API reference](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/)
is built with DocC from the source and published with each change to `main`.

## Guides

The guide in [`docs/`](docs) explains the design questions:

- [A framework for mobile system design](docs/framework.md) — the six steps, the questions to
  ask, the signals reviewers look for.
- Topics: [API design and pagination](docs/topics/api-and-pagination.md) ·
  [Caching and image loading](docs/topics/caching-and-images.md) ·
  [Offline support and sync](docs/topics/offline-and-sync.md) ·
  [Network resilience and real-time updates](docs/topics/resilience-and-real-time.md)
- Case studies: [a photo feed](docs/case-studies/news-feed.md) ·
  [a chat app](docs/case-studies/chat-app.md) ·
  [live ride tracking](docs/case-studies/ride-tracking.md) ·
  [offline music downloads](docs/case-studies/offline-music.md)

The DocC articles explain the code:
[Getting started](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[Building a resilient network layer](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[Designing an offline-first feed](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[Estimating capacity](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## Requirements

| Platform  | Minimum version       |
| --------- | --------------------- |
| iOS       | 17                    |
| macOS     | 14                    |
| Toolchain | Swift 6.2 · Xcode 26+ |

CI builds with the default Xcode of GitHub's `macos-26` runner image. The package is developed
with Xcode 27.

## Architecture

- `Sources/MobileSystemDesign/<Area>/` holds one folder per area: `Caching`, `Resilience`,
  `Pagination`, `Offline`, `Sync` and `Estimation`. The package has no dependencies beyond
  Foundation.
- Shared mutable state lives in actors (`CircuitBreaker`, `Paginator`, `Outbox`); policies,
  caches and clocks are value types you keep inside your own actor.
- Time is always injected — a clock, a `now` parameter or a sleep function — so tests drive it
  by hand and never sleep.
- Inputs that can come from outside the app (remote configuration, HTTP headers, stored files,
  other devices' timestamps) are clamped or rejected at the type's boundary; the tests cover
  NaN, infinity, `Int.max`, negative values and malformed text.
- CI runs `swift test` on macOS, `xcodebuild test` on an iPhone simulator, builds the example
  app for iOS and macOS, and publishes the DocC documentation.

Run the tests locally:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Roadmap

- More case studies: a video feed with prefetching, and a collaborative document.
- An `NWPathMonitor`-based helper that flushes an `Outbox` when the network comes back.
- Add the package to the Swift Package Index; `.spi.yml` is already in the repository.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
