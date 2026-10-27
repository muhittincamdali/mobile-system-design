<!-- i18n-source: README.md@d03b4b12f1062ccc5bd8c9eece9ab260ab980056 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

Ein Leitfaden für den Entwurf der Client-Seite mobiler Apps (Feeds, Chat, Live-Tracking, Offline-Medien) zusammen mit einem Swift-Paket, das dessen Bausteine umsetzt. Er richtet sich an Entwicklerinnen und Entwickler, die sich auf Mobile-System-Design-Interviews vorbereiten, und an Teams, die Design-Dokumente schreiben. Der Leitfaden erklärt jede Entwurfsfrage; das Paket liefert die Antwort als kleine, abhängigkeitsfreie Swift-Typen mit Tests. So kannst du den Code hinter jeder Empfehlung lesen, in der Beispiel-App ausführen und in deinem eigenen Projekt verwenden.

## Highlights

- **Ein Framework und vier Fallstudien**: eine Struktur in sechs Schritten für eine Sitzung von 45 bis 60 Minuten, angewendet auf einen Foto-Feed, eine Chat-App, Live-Tracking einer Fahrt und Offline-Musik-Downloads.
- **Bausteine, die du ausführen kannst**: LRU-Cache, Retry mit Backoff und `Retry-After`, Circuit Breaker, Token Bucket, Cursor-Paginator, persistente Outbox, Hybrid Logical Clock und Last-Writer-Wins-Register sowie Kapazitätsschätzungen.
- **Für fehlerhafte Eingaben gebaut**: Werte aus der Remote-Konfiguration, aus Server-Headern und aus gespeicherten Dateien werden begrenzt oder abgelehnt. Es gibt keinen Absturz bei NaN, Überlauf oder einem fehlerhaften Header, keine Endlosschleife bei einem Server, der seinen Cursor wiederholt, und jede Queue und jeder Cache hat ein Größenlimit.
- **Swift-6-Sprachmodus**: Actors für gemeinsamen Zustand, `Sendable`-Typen, keine Warnungen.
- **Getestet**: 117 Swift-Testing-Tests, ausgeführt unter macOS und in einem iPhone-Simulator, einschließlich der README-Beispiele weiter unten.
- **Eine Beispiel-App**: [SystemDesignLab](Examples/SystemDesignLab) führt jeden Baustein gegen einen simulierten Server aus, den du instabil machen, abschalten oder trennen kannst.

### Was enthalten ist

| Bereich            | Typen            | Seite im Leitfaden                                                                      |
| ------------------ | ---------------- | --------------------------------------------------------------------------------------- |
| Caching            | `LRUCache`    | [Caching und Laden von Bildern](docs/topics/caching-and-images.md)                      |
| Resilienz          | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [Netzwerk-Resilienz und Echtzeit-Updates](docs/topics/resilience-and-real-time.md)      |
| Paginierung        | `Paginator`, `Page` | [API-Design und Paginierung](docs/topics/api-and-pagination.md)                         |
| Offline-Änderungen | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [Offline-Unterstützung und Synchronisierung](docs/topics/offline-and-sync.md)           |
| Synchronisierung   | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [Offline-Unterstützung und Synchronisierung](docs/topics/offline-and-sync.md#conflicts) |
| Schätzung          | `CapacityEstimate`, `ClientBudget` | [Ein Framework für Mobile System Design](docs/framework.md#2-estimate)                  |

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Füge sie oben rechts im Fenster in das Suchfeld ein. Lass **Dependency Rule** auf **Up to Next Major Version** ab `2.0.0` stehen und klicke auf **Add Package**. Wähle im nächsten Fenster neben **MobileSystemDesign** dein App-Target aus und klicke erneut auf **Add Package**.

**2. Modul importieren**

```swift
import MobileSystemDesign
```

Setze diese Zeile an den Anfang der Swift-Datei, in der du das Paket verwendest.

**3. Verwenden**

Ersetze in einer neuen Xcode-App (**File › New › Project… › App**) den gesamten Inhalt von `ContentView.swift` durch:

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

Drücke **Run** (⌘R). Die App zeigt eine Liste, die jedes Mal 20 weitere Zeilen lädt, wenn du ans Ende scrollst, und nach Zeile 99 aufhört. Ersetze `loadPage(after:)` durch deinen API-Aufruf.

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

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

## Verwendung

Die folgenden Beispiele sind aus [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift) kopiert. Die Beispiel-App kompiliert diese Datei, die Test-Suite kompiliert und führt sie aus, und `node scripts/check-readme-samples.mjs` prüft, dass dieses README denselben Code zeigt.

### Eine Anfrage wiederholen und einen fehlerhaften Server nicht mehr aufrufen

Vorübergehende Fehler (Zeitüberschreitungen, Verbindungsabbrüche, `429`, `503`) werden mit exponentiellem Backoff und Jitter wiederholt; fünf Fehler in Folge öffnen den Circuit Breaker, und Aufrufe schlagen dann 30 Sekunden lang sofort fehl, statt auf Zeitüberschreitungen zu warten.

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

### Offline gemachte Änderungen aufbewahren, bis sie gesendet sind

Jede Änderung wird in einer Datei gespeichert, bevor `enqueue` zurückkehrt, beim Flush der Reihe nach vom ältesten Eintrag an gesendet und trägt eine UUID, die du als Idempotency-Key der Anfrage verwenden kannst.

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

### Bilder im Arbeitsspeicher cachen

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

### Eine Änderung auflösen, die auf zwei Geräten gemacht wurde

Eine Hybrid Logical Clock ordnet eine Änderung hinter alles ein, was ihr Gerät bisher gesehen hat. Deshalb gewinnt die spätere Änderung auch dann, wenn die Uhr dieses Geräts nachgeht.

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

### Die Last eines Features schätzen

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

## Beispiel-App

[SystemDesignLab](Examples/SystemDesignLab) hat für jeden Baustein ein eigenes Lab. Der Server läuft in der App, daher funktionieren die Labs ohne Backend und sehen bei jedem Start gleich aus.

| Feed                                                                                                                           | Offline-Likes                                                                                                     | Synchronisierung                                                                                                                        | Schätzer                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="Feed-Lab: Auswahl des Servermodus, Zustand des Circuit Breakers, Anzahl der Anfragen und die geladenen Beiträge" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="Offline-Likes-Lab: Offline-Schalter, drei in der Outbox wartende Änderungen und gelikte Beiträge" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="Sync-Lab: Titel auf Smartphone und Tablet mit Hybrid-Zeitstempeln, nachdem die spätere Änderung des Tablets gewonnen hat" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="Schätzer-Lab: Nutzungseingaben und die daraus berechneten Anfrageraten, Bandbreite und Speicherbedarf" width="200"></picture> |

Öffne `Examples/SystemDesignLab/SystemDesignLab.xcodeproj`, wähle einen iPhone-Simulator oder **My Mac** und drücke **Run**. Die Screenshots erstellt [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) aus der laufenden App.

## Dokumentation

Die [API-Referenz](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/) wird mit DocC aus dem Quellcode erzeugt und bei jeder Änderung an `main` veröffentlicht.

## Anleitungen

Der Leitfaden in [`docs/`](docs) erklärt die Entwurfsfragen:

- [Ein Framework für Mobile System Design](docs/framework.md): die sechs Schritte, die Fragen, die du stellen solltest, und die Signale, auf die Prüfende achten.
- Themen: [API-Design und Paginierung](docs/topics/api-and-pagination.md) ·
  [Caching und Laden von Bildern](docs/topics/caching-and-images.md) ·
  [Offline-Unterstützung und Synchronisierung](docs/topics/offline-and-sync.md) ·
  [Netzwerk-Resilienz und Echtzeit-Updates](docs/topics/resilience-and-real-time.md)
- Fallstudien: [ein Foto-Feed](docs/case-studies/news-feed.md) ·
  [eine Chat-App](docs/case-studies/chat-app.md) ·
  [Live-Tracking einer Fahrt](docs/case-studies/ride-tracking.md) ·
  [Offline-Musik-Downloads](docs/case-studies/offline-music.md)

Die DocC-Artikel erklären den Code:
[Erste Schritte](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[Eine resiliente Netzwerkschicht bauen](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[Einen Offline-First-Feed entwerfen](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[Kapazität schätzen](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## Voraussetzungen

| Plattform | Mindestversion        |
| --------- | --------------------- |
| iOS       | 17                    |
| macOS     | 14                    |
| Toolchain | Swift 6.2 · Xcode 26+ |

CI baut mit dem Standard-Xcode des `macos-26`-Runner-Images von GitHub. Das Paket wird mit Xcode 27 entwickelt.

## Architektur

- `Sources/MobileSystemDesign/<Area>/` enthält einen Ordner pro Bereich: `Caching`, `Resilience`, `Pagination`, `Offline`, `Sync` und `Estimation`. Das Paket hat außer Foundation keine Abhängigkeiten.
- Gemeinsamer veränderlicher Zustand lebt in Actors (`CircuitBreaker`, `Paginator`, `Outbox`); Policies, Caches und Uhren sind Werttypen, die du in deinem eigenen Actor hältst.
- Die Zeit wird immer von außen übergeben (eine Uhr, ein `now`-Parameter oder eine Sleep-Funktion), sodass Tests sie von Hand steuern und nie warten.
- Eingaben, die von außerhalb der App kommen können (Remote-Konfiguration, HTTP-Header, gespeicherte Dateien, Zeitstempel anderer Geräte), werden an der Grenze des Typs begrenzt oder abgelehnt; die Tests decken NaN, Unendlich, `Int.max`, negative Werte und fehlerhaften Text ab.
- CI führt `swift test` unter macOS und `xcodebuild test` in einem iPhone-Simulator aus, baut die Beispiel-App für iOS und macOS und veröffentlicht die DocC-Dokumentation.

Die Tests lokal ausführen:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Roadmap

- Weitere Fallstudien: ein Video-Feed mit Prefetching und ein kollaboratives Dokument.
- Ein Helfer auf Basis von `NWPathMonitor`, der eine `Outbox` per Flush leert, sobald das Netzwerk wieder da ist.
- Das Paket zum Swift Package Index hinzufügen; `.spi.yml` liegt bereits im Repository.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
