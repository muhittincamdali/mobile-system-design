<!-- i18n-source: README.md@e8cdb614e0a73e05a8def8ea58e5820d77a216c2 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="최신 버전: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

모바일 앱의 클라이언트 쪽(피드, 채팅, 실시간 추적, 오프라인 미디어)을 설계하는 방법을 다룬 가이드와, 그 구성 요소를 구현한 Swift 패키지입니다. 모바일 system design 면접을 준비하는 엔지니어와 설계 문서를 작성하는 팀을 위한 자료입니다. 가이드는 각 설계 질문을 설명하고, 패키지는 그 답을 테스트가 포함된 작고 의존성 없는 Swift 타입으로 제공합니다. 모든 권장 사항 뒤에 있는 코드를 읽고, 예제 앱에서 실행하고, 직접 만드는 앱에서 사용할 수 있습니다.

## 주요 기능

- **프레임워크 하나와 사례 연구 네 개** — 45~60분 세션을 위한 여섯 단계 구조를 사진 피드, 채팅 앱, 실시간 승차 추적, 오프라인 음악 다운로드에 적용했습니다.
- **직접 실행해 볼 수 있는 구성 요소** — LRU cache, backoff와 `Retry-After`를 지원하는 재시도, circuit breaker, token bucket, cursor 기반 paginator, 영구 outbox, hybrid logical clock과 last-writer-wins register, 용량 추정.
- **잘못된 입력을 전제로 설계** — 원격 구성, 서버 헤더, 저장된 파일에서 온 값은 범위를 제한하거나 거부합니다. NaN, 오버플로, 형식이 잘못된 헤더 때문에 비정상 종료되지 않으며, cursor를 반복해서 돌려주는 서버에서도 무한 루프에 빠지지 않고, 모든 큐와 캐시에는 크기 제한이 있습니다.
- **Swift 6 언어 모드** — 공유 상태는 actor로 보호하고, `Sendable` 타입을 사용하며, 경고가 없습니다.
- **테스트 완료** — macOS와 iPhone 시뮬레이터에서 실행하는 Swift Testing 테스트 111개이며, 아래 README 샘플도 포함됩니다.
- **예제 앱** — [SystemDesignLab](Examples/SystemDesignLab)은 불안정하게 만들거나, 중단시키거나, 연결을 끊을 수 있는 시뮬레이션 서버를 대상으로 각 구성 요소를 실행합니다.

### 포함된 내용

| 영역          | 타입             | 가이드 페이지                                                                |
| ------------- | ---------------- | ---------------------------------------------------------------------------- |
| 캐싱          | `LRUCache`    | [캐싱과 이미지 로딩](docs/topics/caching-and-images.md)                      |
| 복원력        | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [네트워크 복원력과 실시간 업데이트](docs/topics/resilience-and-real-time.md) |
| 페이지네이션  | `Paginator`, `Page` | [API 설계와 페이지네이션](docs/topics/api-and-pagination.md)                 |
| 오프라인 변경 | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [오프라인 지원과 동기화](docs/topics/offline-and-sync.md)                    |
| 동기화        | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [오프라인 지원과 동기화](docs/topics/offline-and-sync.md#conflicts)          |
| 추정          | `CapacityEstimate`, `ClientBudget` | [모바일 system design 프레임워크](docs/framework.md#2-estimate)              |

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

창 오른쪽 위의 검색 필드에 붙여 넣습니다. **Dependency Rule**은 `2.0.0`부터의 **Up to Next Major Version**으로 둔 채 **Add Package**를 클릭하세요. 다음 창에서 **MobileSystemDesign** 옆에 있는 앱 타깃을 선택하고 **Add Package**를 다시 클릭합니다.

**2. 모듈 가져오기**

```swift
import MobileSystemDesign
```

패키지를 사용하는 Swift 파일의 맨 위에 이 줄을 넣으세요.

**3. 사용하기**

새 Xcode 앱(**File › New › Project… › App**)에서 `ContentView.swift`의 내용을 모두 다음 코드로 바꾸세요.

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

**Run**(⌘R)을 누르세요. 목록 끝까지 스크롤할 때마다 20행씩 더 불러오고, 99번째 행에서 멈춥니다. `loadPage(after:)`를 직접 만든 API 호출로 바꾸세요.

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

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

## 사용법

아래 샘플은 [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift)에서 복사한 것입니다. 예제 앱이 이 파일을 컴파일하고, 테스트 스위트가 컴파일해서 실행하며, `node scripts/check-readme-samples.mjs`가 이 README에 같은 코드가 실려 있는지 확인합니다.

### 요청을 재시도하고, 실패하는 서버 호출은 중단하기

일시적인 실패(타임아웃, 연결 끊김, `429`, `503`)는 지수 backoff와 jitter로 재시도합니다. 연속으로 다섯 번 실패하면 circuit breaker가 열리고, 이후 30초 동안은 타임아웃을 기다리지 않고 호출이 즉시 실패합니다.

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

### 오프라인에서 만든 변경을 전송될 때까지 보관하기

각 변경은 `enqueue`가 반환되기 전에 파일에 저장되고, flush할 때 오래된 것부터 순서대로 전송되며, 요청의 idempotency key로 쓸 수 있는 UUID를 가집니다.

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

### 이미지를 메모리에 캐시하기

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

### 두 기기에서 한 편집 충돌 해결하기

hybrid logical clock은 편집을 해당 기기가 지금까지 본 모든 것보다 뒤에 놓습니다. 따라서 기기의 시계가 뒤처져 있어도 나중에 한 편집이 이깁니다.

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

### 기능의 부하 추정하기

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

## 예제 앱

[SystemDesignLab](Examples/SystemDesignLab)에는 구성 요소마다 하나씩 랩이 있습니다. 서버가 앱 안에서 실행되므로 랩은 백엔드 없이 동작하며 실행할 때마다 똑같이 보입니다.

| 피드        | 오프라인 좋아요                                                           | 동기화        | 추정기                                                                                       |
| ----------- | ------------------------------------------------------------------------- | ------------- | -------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="피드 랩: 서버 모드 선택기, circuit breaker 상태, 요청 수, 불러온 게시물" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="오프라인 좋아요 랩: 오프라인 스위치, outbox에서 대기 중인 변경 세 개, 좋아요를 누른 게시물" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="동기화 랩: 태블릿의 나중 편집이 이긴 뒤의 휴대폰과 태블릿 제목 및 hybrid 타임스탬프" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="추정기 랩: 사용량 입력과 그 결과인 요청 속도, 대역폭, 저장 공간" width="200"></picture> |

`Examples/SystemDesignLab/SystemDesignLab.xcodeproj`를 열고 iPhone 시뮬레이터 또는 **My Mac**을 선택한 다음 **Run**을 누르세요. 스크린샷은 실행 중인 앱에서 [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh)로 촬영합니다.

## 문서

[API 레퍼런스](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/)는 소스에서 DocC로 생성하며, `main`이 바뀔 때마다 게시됩니다.

## 가이드

[`docs/`](docs)의 가이드는 설계 질문을 설명합니다.

- [모바일 system design 프레임워크](docs/framework.md) — 여섯 단계, 던져야 할 질문, 리뷰어가 보는 신호.
- 주제: [API 설계와 페이지네이션](docs/topics/api-and-pagination.md) ·
  [캐싱과 이미지 로딩](docs/topics/caching-and-images.md) ·
  [오프라인 지원과 동기화](docs/topics/offline-and-sync.md) ·
  [네트워크 복원력과 실시간 업데이트](docs/topics/resilience-and-real-time.md)
- 사례 연구: [사진 피드](docs/case-studies/news-feed.md) ·
  [채팅 앱](docs/case-studies/chat-app.md) ·
  [실시간 승차 추적](docs/case-studies/ride-tracking.md) ·
  [오프라인 음악 다운로드](docs/case-studies/offline-music.md)

DocC 문서는 코드를 설명합니다.
[시작하기](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[복원력 있는 네트워크 계층 만들기](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[오프라인 우선 피드 설계하기](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[용량 추정하기](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## 요구 사항

| 플랫폼 | 최소 버전             |
| ------ | --------------------- |
| iOS    | 17                    |
| macOS  | 14                    |
| 툴체인 | Swift 6.2 · Xcode 26+ |

CI는 GitHub의 `macos-26` runner 이미지에 포함된 기본 Xcode로 빌드합니다. 패키지는 Xcode 27로 개발합니다.

## 아키텍처

- `Sources/MobileSystemDesign/<Area>/`에는 영역마다 폴더가 하나씩 있습니다: `Caching`, `Resilience`, `Pagination`, `Offline`, `Sync`, `Estimation`. 패키지는 Foundation 외에 의존성이 없습니다.
- 공유되는 가변 상태는 actor에 둡니다(`CircuitBreaker`, `Paginator`, `Outbox`). policy, 캐시, 시계는 값 타입이며, 직접 만든 actor 안에 보관해서 사용합니다.
- 시간은 항상 외부에서 주입합니다(시계, `now` 매개변수, sleep 함수). 그래서 테스트는 시간을 직접 진행시키며 실제로 기다리지 않습니다.
- 앱 밖에서 올 수 있는 입력(원격 구성, HTTP 헤더, 저장된 파일, 다른 기기의 타임스탬프)은 타입의 경계에서 범위를 제한하거나 거부합니다. 테스트는 NaN, 무한대, `Int.max`, 음수 값, 형식이 잘못된 텍스트를 다룹니다.
- CI는 macOS에서 `swift test`를, iPhone 시뮬레이터에서 `xcodebuild test`를 실행하고, 예제 앱을 iOS와 macOS용으로 빌드하며, DocC 문서를 게시합니다.

테스트를 로컬에서 실행하려면 다음과 같이 하세요.

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 로드맵

- 사례 연구 추가: 프리페치를 사용하는 동영상 피드와 공동 편집 문서.
- 네트워크가 복구되면 `Outbox`를 flush하는 `NWPathMonitor` 기반 도우미.
- 패키지를 Swift Package Index에 추가하기. `.spi.yml`은 이미 저장소에 있습니다.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
