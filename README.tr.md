<!-- i18n-source: README.md@19b6da73c1aed09ceed6440ee0c92b4f65c589a8 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

Mobil uygulamaların istemci tarafını tasarlamak için bir rehber (akışlar, sohbet, canlı takip,
çevrimdışı medya) ve bu rehberin yapı taşlarını uygulayan bir Swift paketi. Mobil system design
mülakatlarına hazırlanan mühendislere ve tasarım dokümanı yazan ekiplere yöneliktir. Rehber her
tasarım sorusunu açıklar; paket cevabı testli, bağımlılıksız küçük Swift tipleri olarak sunar.
Böylece her önerinin arkasındaki kodu okuyabilir, örnek uygulamada çalıştırabilir ve kendi
projenizde kullanabilirsiniz.

## Öne çıkanlar

- **Bir çerçeve ve dört vaka incelemesi** — 45–60 dakikalık bir oturum için altı adımlı bir yapı;
  fotoğraf akışı, sohbet uygulaması, canlı yolculuk takibi ve çevrimdışı müzik indirme
  örneklerine uygulanır.
- **Çalıştırabileceğiniz yapı taşları** — LRU cache, backoff ve `Retry-After` destekli yeniden
  deneme, circuit breaker, token bucket, cursor tabanlı paginator, kalıcı outbox, hybrid logical
  clock ve last-writer-wins register, kapasite tahminleri.
- **Hatalı girdiye karşı tasarlandı** — uzak yapılandırmadan, sunucu başlıklarından ve saklanan
  dosyalardan gelen değerler sınırlandırılır veya reddedilir: NaN, taşma ya da bozuk bir başlık
  yüzünden çökme yok, cursor'ını tekrarlayan bir sunucuda sonsuz döngü yok, her kuyruğun ve
  cache'in bir boyut sınırı var.
- **Swift 6 dil modu** — paylaşılan durum için actor'lar, `Sendable` tipler, uyarı yok.
- **Testli** — macOS'ta ve bir iPhone simülatöründe çalışan 117 Swift Testing testi; aşağıdaki
  README örnekleri de bunların arasında.
- **Bir örnek uygulama** — [SystemDesignLab](Examples/SystemDesignLab), her yapı taşını
  kararsız hâle getirebileceğiniz, kapatabileceğiniz ya da bağlantısını kesebileceğiniz
  simüle bir sunucuya karşı çalıştırır.

### Neler var

| Alan                     | Tipler           | Rehber sayfası                                                                              |
| ------------------------ | ---------------- | ------------------------------------------------------------------------------------------- |
| Caching                  | `LRUCache`    | [Caching ve görsel yükleme](docs/topics/caching-and-images.md)                              |
| Dayanıklılık             | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [Ağ dayanıklılığı ve gerçek zamanlı güncellemeler](docs/topics/resilience-and-real-time.md) |
| Sayfalama                | `Paginator`, `Page` | [API tasarımı ve sayfalama](docs/topics/api-and-pagination.md)                              |
| Çevrimdışı değişiklikler | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [Çevrimdışı destek ve senkronizasyon](docs/topics/offline-and-sync.md)                      |
| Senkronizasyon           | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [Çevrimdışı destek ve senkronizasyon](docs/topics/offline-and-sync.md#conflicts)            |
| Tahmin                   | `CapacityEstimate`, `ClientBudget` | [Mobil system design için bir çerçeve](docs/framework.md#2-estimate)                        |

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Bunu pencerenin sağ üstündeki arama alanına yapıştırın. **Dependency Rule** ayarını `2.0.0`
sürümünden başlayan **Up to Next Major Version** olarak bırakın, sonra **Add Package**'a tıklayın.
Açılan pencerede **MobileSystemDesign** yanında uygulama hedefinizi seçin ve **Add Package**'a
yeniden tıklayın.

**2. Modülü içe aktarın**

```swift
import MobileSystemDesign
```

Bu satırı paketi kullandığınız Swift dosyasının en üstüne koyun.

**3. Kullanın**

Yeni bir Xcode uygulamasında (**File › New › Project… › App**) `ContentView.swift` içindeki her şeyi
şununla değiştirin:

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

**Run**'a (⌘R) basın. Uygulama, listenin sonuna her ulaşışınızda 20 satır daha yükleyen bir liste
gösterir ve 99. satırdan sonra durur. `loadPage(after:)` yerine kendi API çağrınızı koyun.

## Kurulum

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Ya da `Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

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

## Kullanım

Aşağıdaki örnekler
[`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift)
dosyasından kopyalanmıştır. Örnek uygulama bu dosyayı derler, test paketi derleyip çalıştırır ve
`node scripts/check-readme-samples.mjs` bu README'nin aynı kodu gösterdiğini denetler.

### Bir isteği yeniden deneyin ve hata veren sunucuyu aramayı bırakın

Geçici hatalar (zaman aşımları, kopan bağlantılar, `429`, `503`) üstel backoff ve jitter ile
yeniden denenir; art arda beş hata circuit breaker'ı açar ve çağrılar, zaman aşımlarını beklemek
yerine 30 saniye boyunca hemen başarısız olur.

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

### Çevrimdışı yapılan değişiklikleri gönderilene kadar saklayın

Her değişiklik, `enqueue` dönmeden önce bir dosyaya kaydedilir, flush ettiğinizde en eskiden
başlayarak gönderilir ve isteğin idempotency anahtarı olarak kullanabileceğiniz bir UUID taşır.

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

### Görselleri bellekte önbelleğe alın

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

### İki cihazda yapılan bir düzenlemeyi çözün

Hybrid logical clock, bir düzenlemeyi cihazın o ana kadar gördüğü her şeyden sonraya yerleştirir;
böylece cihazın saati geride olsa bile sonraki düzenleme kazanır.

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

### Bir özelliğin yükünü tahmin edin

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

## Örnek uygulama

[SystemDesignLab](Examples/SystemDesignLab) her yapı taşı için bir laboratuvar içerir. Sunucusu
uygulamanın içinde çalıştığından laboratuvarlar bir backend olmadan çalışır ve her çalıştırmada
aynı görünür.

| Akış        | Çevrimdışı beğeniler                                                                                   | Senkronizasyon | Tahmin aracı                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------ | -------------- | ------------------------------------------------------------------------------------------------------------------ |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="Akış laboratuvarı: sunucu modu seçici, circuit breaker durumu, istek sayıları ve yüklenen gönderiler" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="Çevrimdışı beğeniler laboratuvarı: çevrimdışı anahtarı, outbox'ta bekleyen üç değişiklik ve beğenilen gönderiler" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="Senkronizasyon laboratuvarı: tabletin sonraki düzenlemesi kazandıktan sonra hybrid zaman damgalarıyla telefon ve tablet başlıkları" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="Tahmin laboratuvarı: kullanım girdileri ile ortaya çıkan istek hızları, bant genişliği ve depolama" width="200"></picture> |

`Examples/SystemDesignLab/SystemDesignLab.xcodeproj` dosyasını açın, bir iPhone simülatörü ya da
**My Mac** seçin ve **Run**'a basın. Ekran görüntüleri çalışan uygulamadan
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) ile alınır.

## Dokümantasyon

[API başvuru belgeleri](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/)
kaynak koddan DocC ile üretilir ve `main` dalındaki her değişiklikte yayımlanır.

## Rehberler

[`docs/`](docs) altındaki rehber tasarım sorularını açıklar:

- [Mobil system design için bir çerçeve](docs/framework.md) — altı adım, sorulacak sorular ve
  değerlendiricilerin aradığı işaretler.
- Konular: [API tasarımı ve sayfalama](docs/topics/api-and-pagination.md) ·
  [Caching ve görsel yükleme](docs/topics/caching-and-images.md) ·
  [Çevrimdışı destek ve senkronizasyon](docs/topics/offline-and-sync.md) ·
  [Ağ dayanıklılığı ve gerçek zamanlı güncellemeler](docs/topics/resilience-and-real-time.md)
- Vaka incelemeleri: [bir fotoğraf akışı](docs/case-studies/news-feed.md) ·
  [bir sohbet uygulaması](docs/case-studies/chat-app.md) ·
  [canlı yolculuk takibi](docs/case-studies/ride-tracking.md) ·
  [çevrimdışı müzik indirme](docs/case-studies/offline-music.md)

DocC makaleleri kodu açıklar:
[Başlarken](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[Dayanıklı bir ağ katmanı kurmak](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[Çevrimdışı öncelikli bir akış tasarlamak](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[Kapasite tahmini](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## Gereksinimler

| Platform     | En düşük sürüm        |
| ------------ | --------------------- |
| iOS          | 17                    |
| macOS        | 14                    |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

CI, GitHub'ın `macos-26` runner imajındaki varsayılan Xcode ile derleme yapar. Paket Xcode 27 ile
geliştirilmiştir.

## Mimari

- `Sources/MobileSystemDesign/<Area>/` her alan için bir klasör içerir: `Caching`, `Resilience`,
  `Pagination`, `Offline`, `Sync` ve `Estimation`. Paketin Foundation dışında bağımlılığı yoktur.
- Paylaşılan değiştirilebilir durum actor'larda tutulur (`CircuitBreaker`, `Paginator`, `Outbox`);
  policy'ler, cache'ler ve saatler kendi actor'ınızın içinde tuttuğunuz value type'lardır.
- Zaman her zaman dışarıdan verilir (bir saat, bir `now` parametresi ya da bir sleep fonksiyonu);
  böylece testler zamanı elle ilerletir ve hiç beklemez.
- Uygulamanın dışından gelebilecek girdiler (uzak yapılandırma, HTTP başlıkları, saklanan dosyalar,
  başka cihazların zaman damgaları) tipin sınırında kısıtlanır ya da reddedilir; testler NaN,
  sonsuz, `Int.max`, negatif değerleri ve bozuk metni kapsar.
- CI, macOS'ta `swift test`, bir iPhone simülatöründe `xcodebuild test` çalıştırır, örnek
  uygulamayı iOS ve macOS için derler ve DocC dokümantasyonunu yayımlar.

Testleri yerelde çalıştırmak için:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Yol haritası

- Daha fazla vaka incelemesi: prefetching'li bir video akışı ve ortak çalışılan bir doküman.
- Ağ geri geldiğinde bir `Outbox`'ı flush eden, `NWPathMonitor` tabanlı bir yardımcı.
- Paketi Swift Package Index'e ekleme; `.spi.yml` depoda zaten var.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
