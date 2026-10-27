# Getting started

Add the package to an app and load an infinite list in a few lines.

## Overview

The package has one library, ``MobileSystemDesign``, with no dependencies. It needs iOS 17 or
macOS 14 and Swift 6.2 or later.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, paste the repository URL into the
search field and click **Add Package**:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

In the next window, choose your app target next to **MobileSystemDesign** and click **Add
Package** again.

With Swift Package Manager, add the dependency to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/mobile-system-design.git", from: "2.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "MobileSystemDesign", package: "mobile-system-design")
    ])
]
```

### Load a paginated list

``Paginator`` asks a closure for one page at a time. The closure receives the cursor of the
page to load (`nil` for the first page) and returns a ``Page`` with the items and the next
cursor:

```swift
import MobileSystemDesign
import SwiftUI

struct FeedItem: Identifiable, Sendable {
    let id: Int
}

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

Replace `loadPage(after:)` with your API call. The paginator makes sure the list never asks
for the same page twice at once, skips items it already has, and stops when the server
returns no next cursor, repeats a cursor, or keeps returning nothing new.

### Make the request resilient

Wrap the API call in a ``Retrier`` and a ``CircuitBreaker``. The retrier repeats temporary
failures with exponential backoff; the breaker stops calling a server that keeps failing:

```swift
let retrier = Retrier(policy: RetryPolicy(maxAttempts: 3))
let breaker = CircuitBreaker()

let page = try await retrier.run { _ in
    try await breaker.run { try await api.page(after: cursor) }
}
```

<doc:ResilientNetworking> explains the policies, and <doc:OfflineFirstFeeds> adds a cache,
offline changes and sync.

### Try the example app

The repository's `Examples/SystemDesignLab` app shows each type at work against a simulated
server that can be made slow, flaky, down or offline. Open
`Examples/SystemDesignLab/SystemDesignLab.xcodeproj` and press **Run**.
