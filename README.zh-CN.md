<!-- i18n-source: README.md@19b6da73c1aed09ceed6440ee0c92b4f65c589a8 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

这是一份设计移动应用客户端的指南，涵盖信息流、聊天、实时追踪和离线媒体，并附带一个实现其基础组件的 Swift 软件包。它面向准备移动端 system design 面试的工程师，以及需要撰写设计文档的团队。指南讲解每一个设计问题；软件包则以小巧、无依赖、带测试的 Swift 类型给出答案，你可以阅读每条建议背后的代码，在示例应用中运行它，并用到自己的项目里。

## 亮点

- **一套框架和四个案例分析**：为 45–60 分钟的面试设计的六步结构，应用于图片信息流、聊天应用、实时行程追踪和离线音乐下载。
- **可以运行的基础组件**：LRU cache、带 backoff 和 `Retry-After` 的重试、circuit breaker、token bucket、基于 cursor 的 paginator、持久化 outbox、hybrid logical clock 与 last-writer-wins register，以及容量估算。
- **为错误输入而设计**：来自远程配置、服务器响应头和已存储文件的值都会被限制范围或直接拒绝。遇到 NaN、溢出或格式错误的响应头不会崩溃，服务器反复返回同一个 cursor 也不会陷入死循环，所有队列和缓存都有大小上限。
- **Swift 6 语言模式**：用 actor 保护共享状态，使用 `Sendable` 类型，没有警告。
- **经过测试**：117 个 Swift Testing 测试，在 macOS 和 iPhone 模拟器上运行，其中包括下面的 README 示例。
- **示例应用**：[SystemDesignLab](Examples/SystemDesignLab) 针对一个模拟服务器运行每个基础组件，你可以让这个服务器变得不稳定、宕机或断开连接。

### 包含的内容

| 领域     | 类型             | 指南页面                                                      |
| -------- | ---------------- | ------------------------------------------------------------- |
| 缓存     | `LRUCache`    | [缓存与图片加载](docs/topics/caching-and-images.md)           |
| 韧性     | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [网络韧性与实时更新](docs/topics/resilience-and-real-time.md) |
| 分页     | `Paginator`, `Page` | [API 设计与分页](docs/topics/api-and-pagination.md)           |
| 离线变更 | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [离线支持与同步](docs/topics/offline-and-sync.md)             |
| 同步     | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [离线支持与同步](docs/topics/offline-and-sync.md#conflicts)   |
| 估算     | `CapacityEstimate`, `ClientBudget` | [移动端 system design 框架](docs/framework.md#2-estimate)     |

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

将它粘贴到窗口右上角的搜索框中。把 **Dependency Rule** 保持为从 `2.0.0` 开始的 **Up to Next Major Version**，然后点击 **Add Package**。在接下来的窗口中，在 **MobileSystemDesign** 旁边选择你的应用 target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import MobileSystemDesign
```

把这一行放在你使用该软件包的 Swift 文件顶部。

**3. 开始使用**

在新建的 Xcode 应用（**File › New › Project… › App**）中，将 `ContentView.swift` 的全部内容替换为：

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

点击 **Run**（⌘R）。应用会显示一个列表，每次滚动到底部就再加载 20 行，到第 99 行后停止。把 `loadPage(after:)` 换成你自己的 API 调用即可。

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

或者将其添加到 `Package.swift` 的 `dependencies` 中：

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

## 使用方法

下面的示例复制自 [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift)。示例应用会编译该文件，测试套件会编译并运行它，`node scripts/check-readme-samples.mjs` 则会检查本 README 展示的代码与它一致。

### 重试请求，并在服务器持续失败时停止调用

临时性故障（超时、连接中断、`429`、`503`）会以指数 backoff 加 jitter 的方式重试；连续失败五次后 circuit breaker 打开，之后的 30 秒内调用会立即失败，而不必等待超时。

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

### 把离线时产生的变更保存到发送为止

每个变更都会在 `enqueue` 返回之前保存到文件中；调用 flush 时按从旧到新的顺序发送，并附带一个 UUID，可以用作请求的 idempotency key。

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

### 在内存中缓存图片

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

### 解决两台设备上的编辑冲突

hybrid logical clock 会把一次编辑排在其所在设备已见过的所有事件之后，因此即使该设备的时钟落后，较晚的编辑依然胜出。

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

    // The phone's clock checks the tablet's timestamp before the copy can win.
    try phoneTitle.merge(tabletTitle, using: &phone, physicalTime: now.addingTimeInterval(1))
    return phoneTitle.value // "Weekend groceries"
}
```

### 估算一个功能的负载

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

## 示例应用

[SystemDesignLab](Examples/SystemDesignLab) 为每个基础组件提供了一个实验页面。它的服务器运行在应用内部，因此这些实验无需后端即可使用，而且每次运行的表现都一样。

| 信息流      | 离线点赞                                                                     | 同步          | 估算器                                                              |
| ----------- | ---------------------------------------------------------------------------- | ------------- | ------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="信息流实验：服务器模式选择器、circuit breaker 状态、请求计数和已加载的帖子" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="离线点赞实验：离线开关、outbox 中等待发送的三个变更和已点赞的帖子" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="同步实验：平板较晚的编辑胜出后，手机和平板的标题及 hybrid 时间戳" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="估算器实验：使用量输入，以及得出的请求速率、带宽和存储" width="200"></picture> |

打开 `Examples/SystemDesignLab/SystemDesignLab.xcodeproj`，选择一个 iPhone 模拟器或 **My Mac**，然后点击 **Run**。截图由 [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) 从运行中的应用截取。

## 文档

[API 参考文档](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/)由 DocC 根据源码生成，并在 `main` 分支每次变更时发布。

## 指南

[`docs/`](docs) 中的指南讲解各个设计问题：

- [移动端 system design 框架](docs/framework.md)：六个步骤、该问的问题，以及评审者关注的信号。
- 主题：[API 设计与分页](docs/topics/api-and-pagination.md) ·
  [缓存与图片加载](docs/topics/caching-and-images.md) ·
  [离线支持与同步](docs/topics/offline-and-sync.md) ·
  [网络韧性与实时更新](docs/topics/resilience-and-real-time.md)
- 案例分析：[图片信息流](docs/case-studies/news-feed.md) ·
  [聊天应用](docs/case-studies/chat-app.md) ·
  [实时行程追踪](docs/case-studies/ride-tracking.md) ·
  [离线音乐下载](docs/case-studies/offline-music.md)

DocC 文章讲解代码：
[入门](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[构建有韧性的网络层](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[设计离线优先的信息流](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[估算容量](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## 系统要求

| 平台   | 最低版本              |
| ------ | --------------------- |
| iOS    | 17                    |
| macOS  | 14                    |
| 工具链 | Swift 6.2 · Xcode 26+ |

CI 使用 GitHub `macos-26` runner 镜像中的默认 Xcode 进行构建。该软件包使用 Xcode 27 开发。

## 架构

- `Sources/MobileSystemDesign/<Area>/` 为每个领域提供一个文件夹：`Caching`、`Resilience`、`Pagination`、`Offline`、`Sync` 和 `Estimation`。软件包除 Foundation 外没有其他依赖。
- 共享的可变状态放在 actor 中（`CircuitBreaker`、`Paginator`、`Outbox`）；policy、缓存和时钟是值类型，由你放在自己的 actor 里。
- 时间始终由外部注入，可以是时钟、`now` 参数或 sleep 函数，因此测试可以手动推进时间，从不真正等待。
- 可能来自应用之外的输入（远程配置、HTTP 响应头、已存储文件、其他设备的时间戳）会在类型的边界处被限制范围或被拒绝；测试覆盖了 NaN、无穷大、`Int.max`、负值和格式错误的文本。
- CI 在 macOS 上运行 `swift test`，在 iPhone 模拟器上运行 `xcodebuild test`，为 iOS 和 macOS 构建示例应用，并发布 DocC 文档。

在本地运行测试：

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 路线图

- 更多案例分析：带预取的视频信息流，以及协作文档。
- 一个基于 `NWPathMonitor` 的辅助工具，在网络恢复时 flush `Outbox`。
- 将软件包添加到 Swift Package Index；`.spi.yml` 已经在仓库中。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
