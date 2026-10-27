<!-- i18n-source: README.md@d03b4b12f1062ccc5bd8c9eece9ab260ab980056 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

モバイルアプリのクライアント側（フィード、チャット、ライブトラッキング、オフラインメディア）を設計するためのガイドと、その構成要素を実装した Swift パッケージです。モバイル system design の面接に備えるエンジニアや、設計ドキュメントを書くチームを対象としています。ガイドは各設計上の問いを解説し、パッケージはその答えを、テスト付きで依存関係のない小さな Swift の型として提供します。すべての推奨事項の裏にあるコードを読み、サンプルアプリで動かし、自分のプロジェクトで使えます。

## 主な特長

- **フレームワークと 4 つのケーススタディ** — 45～60 分のセッション向けの 6 ステップの構成を、写真フィード、チャットアプリ、ライブ配車トラッキング、オフライン音楽ダウンロードに適用しています。
- **動かせる構成要素** — LRU cache、backoff と `Retry-After` に対応したリトライ、circuit breaker、token bucket、cursor 方式の paginator、永続的な outbox、hybrid logical clock と last-writer-wins register、容量の見積もり。
- **不正な入力を想定した設計** — リモート構成、サーバーヘッダー、保存済みファイルから来る値は、範囲内に収めるか拒否します。NaN、オーバーフロー、不正な形式のヘッダーでクラッシュせず、同じ cursor を返し続けるサーバーでも無限ループにならず、すべてのキューとキャッシュにサイズ上限があります。
- **Swift 6 言語モード** — 共有状態は actor で保護し、`Sendable` な型を使い、警告はありません。
- **テスト済み** — 117 個の Swift Testing テストを macOS と iPhone シミュレータで実行しており、以下の README のサンプルも含まれます。
- **サンプルアプリ** — [SystemDesignLab](Examples/SystemDesignLab) は、不安定にしたり、停止させたり、接続を切ったりできるシミュレートされたサーバーに対して、各構成要素を動かします。

### 含まれるもの

| 分野             | 型               | ガイドのページ                                                                      |
| ---------------- | ---------------- | ----------------------------------------------------------------------------------- |
| キャッシュ       | `LRUCache`    | [キャッシュと画像の読み込み](docs/topics/caching-and-images.md)                     |
| 耐障害性         | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [ネットワークの耐障害性とリアルタイム更新](docs/topics/resilience-and-real-time.md) |
| ページネーション | `Paginator`, `Page` | [API 設計とページネーション](docs/topics/api-and-pagination.md)                     |
| オフラインの変更 | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [オフライン対応と同期](docs/topics/offline-and-sync.md)                             |
| 同期             | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [オフライン対応と同期](docs/topics/offline-and-sync.md#conflicts)                   |
| 見積もり         | `CapacityEstimate`, `ClientBudget` | [モバイル system design のフレームワーク](docs/framework.md#2-estimate)             |

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

ウィンドウ右上の検索欄に貼り付けてください。**Dependency Rule** は `2.0.0` からの **Up to Next Major Version** のままにして、**Add Package** をクリックします。次のウィンドウで、**MobileSystemDesign** の横にあるアプリのターゲットを選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import MobileSystemDesign
```

パッケージを使う Swift ファイルの先頭に、この行を入れます。

**3. 使ってみる**

新しい Xcode アプリ（**File › New › Project… › App**）で、`ContentView.swift` の中身をすべて次のコードに置き換えます。

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

**Run**（⌘R）を押します。リストの末尾までスクロールするたびに 20 行ずつ読み込まれ、99 行目で止まります。`loadPage(after:)` を自分の API 呼び出しに置き換えてください。

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

または `Package.swift` の `dependencies` に追加します。

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

## 使い方

以下のサンプルは [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift) からコピーしたものです。サンプルアプリがこのファイルをコンパイルし、テストスイートがコンパイルして実行し、`node scripts/check-readme-samples.mjs` がこの README に同じコードが載っていることを確認します。

### リクエストをリトライし、失敗し続けるサーバーへの呼び出しをやめる

一時的な障害（タイムアウト、接続断、`429`、`503`）は、指数 backoff と jitter でリトライされます。5 回連続で失敗すると circuit breaker が開き、その後 30 秒間は、タイムアウトを待たずに呼び出しがすぐ失敗します。

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

### オフラインで行った変更を、送信されるまで保持する

各変更は `enqueue` が戻る前にファイルへ保存され、flush すると古いものから順に送信されます。また、リクエストの idempotency key として使える UUID が付きます。

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

### 画像をメモリにキャッシュする

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

### 2 台のデバイスで行われた編集を解決する

hybrid logical clock は、編集をそのデバイスがそれまでに見たすべてのものより後に並べます。そのため、デバイスの時計が遅れていても、後から行った編集が勝ちます。

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

### 機能の負荷を見積もる

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

## サンプルアプリ

[SystemDesignLab](Examples/SystemDesignLab) には、構成要素ごとに 1 つのラボがあります。サーバーはアプリ内で動作するため、ラボはバックエンドなしで動き、実行のたびに同じ結果になります。

| フィード    | オフラインのいいね                                                                             | 同期          | 見積もりツール                                                                                 |
| ----------- | ---------------------------------------------------------------------------------------------- | ------------- | ---------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="フィードのラボ：サーバーモードの選択、circuit breaker の状態、リクエスト数、読み込まれた投稿" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="オフラインいいねのラボ：オフラインのスイッチ、outbox で待機中の 3 件の変更、いいねされた投稿" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="同期のラボ：タブレットの後からの編集が勝った後の、スマートフォンとタブレットのタイトルと hybrid タイムスタンプ" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="見積もりツールのラボ：利用状況の入力と、その結果のリクエストレート、帯域幅、ストレージ" width="200"></picture> |

`Examples/SystemDesignLab/SystemDesignLab.xcodeproj` を開き、iPhone シミュレータまたは **My Mac** を選んで **Run** を押します。スクリーンショットは、実行中のアプリから [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) で撮影しています。

## ドキュメント

[API リファレンス](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/)は、ソースから DocC で生成し、`main` への変更のたびに公開しています。

## ガイド

[`docs/`](docs) のガイドは、設計上の問いを解説します。

- [モバイル system design のフレームワーク](docs/framework.md) — 6 つのステップ、確認すべき質問、レビュアーが見るポイント。
- トピック：[API 設計とページネーション](docs/topics/api-and-pagination.md) ·
  [キャッシュと画像の読み込み](docs/topics/caching-and-images.md) ·
  [オフライン対応と同期](docs/topics/offline-and-sync.md) ·
  [ネットワークの耐障害性とリアルタイム更新](docs/topics/resilience-and-real-time.md)
- ケーススタディ：[写真フィード](docs/case-studies/news-feed.md) ·
  [チャットアプリ](docs/case-studies/chat-app.md) ·
  [ライブ配車トラッキング](docs/case-studies/ride-tracking.md) ·
  [オフライン音楽ダウンロード](docs/case-studies/offline-music.md)

DocC の記事はコードを解説します。
[はじめに](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[耐障害性のあるネットワーク層を作る](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[オフラインファーストのフィードを設計する](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[容量を見積もる](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## 動作要件

| プラットフォーム | 最小バージョン        |
| ---------------- | --------------------- |
| iOS              | 17                    |
| macOS            | 14                    |
| ツールチェーン   | Swift 6.2 · Xcode 26+ |

CI は、GitHub の `macos-26` runner イメージに入っている既定の Xcode でビルドします。パッケージは Xcode 27 で開発しています。

## アーキテクチャ

- `Sources/MobileSystemDesign/<Area>/` には、分野ごとに 1 つのフォルダーがあります：`Caching`、`Resilience`、`Pagination`、`Offline`、`Sync`、`Estimation`。パッケージは Foundation 以外に依存しません。
- 共有される可変状態は actor に置きます（`CircuitBreaker`、`Paginator`、`Outbox`）。policy、キャッシュ、時計は値型で、自分の actor の中に持たせて使います。
- 時間は常に外から渡します（時計、`now` パラメータ、sleep 関数のいずれか）。そのため、テストでは時間を手動で進められ、実際に待つことはありません。
- アプリの外から来る可能性のある入力（リモート構成、HTTP ヘッダー、保存済みファイル、他のデバイスのタイムスタンプ）は、型の境界で範囲内に収めるか拒否します。テストは、NaN、無限大、`Int.max`、負の値、不正な形式のテキストを対象にしています。
- CI は macOS で `swift test` を、iPhone シミュレータで `xcodebuild test` を実行し、サンプルアプリを iOS と macOS 向けにビルドし、DocC ドキュメントを公開します。

テストをローカルで実行するには、次のようにします。

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## ロードマップ

- ケーススタディの追加：プリフェッチ付きの動画フィードと、共同編集ドキュメント。
- ネットワークが復旧したときに `Outbox` を flush する、`NWPathMonitor` ベースのヘルパー。
- パッケージを Swift Package Index に追加する（`.spi.yml` はすでにリポジトリにあります）。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
