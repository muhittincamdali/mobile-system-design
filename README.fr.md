<!-- i18n-source: README.md@19b6da73c1aed09ceed6440ee0c92b4f65c589a8 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="Dernière version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

Un guide pour concevoir le côté client des applications mobiles (fils d’actualité, messagerie, suivi en direct, médias hors ligne), accompagné d’un paquet Swift qui implémente ses briques de base. Il s’adresse aux ingénieurs qui préparent des entretiens de mobile system design et aux équipes qui rédigent des documents de conception. Le guide explique chaque question de conception ; le paquet donne la réponse sous forme de petits types Swift sans dépendances et testés, pour que vous puissiez lire le code derrière chaque recommandation, l’exécuter dans l’application d’exemple et l’utiliser dans la vôtre.

## Points forts

- **Un cadre de travail et quatre études de cas** : une structure en six étapes pour une session de 45 à 60 minutes, appliquée à un fil de photos, à une application de messagerie, au suivi en direct d’une course et aux téléchargements de musique hors ligne.
- **Des briques de base que vous pouvez exécuter** : LRU cache, nouvelles tentatives avec backoff et `Retry-After`, circuit breaker, token bucket, paginator à base de cursor, outbox persistant, hybrid logical clock et last-writer-wins register, estimations de capacité.
- **Conçu pour les entrées invalides** : les valeurs issues de la configuration distante, des en-têtes du serveur et des fichiers stockés sont bornées ou rejetées. Aucun plantage sur NaN, un dépassement ou un en-tête mal formé, aucune boucle infinie avec un serveur qui répète son cursor, et chaque file et chaque cache a une limite de taille.
- **Mode de langage Swift 6** : des actors pour l’état partagé, des types `Sendable`, aucun avertissement.
- **Testé** : 117 tests Swift Testing, exécutés sur macOS et sur un simulateur d’iPhone, y compris les exemples du README ci-dessous.
- **Une application d’exemple** : [SystemDesignLab](Examples/SystemDesignLab) exécute chaque brique de base face à un serveur simulé que vous pouvez rendre instable, éteindre ou déconnecter.

### Contenu

| Domaine                  | Types            | Page du guide                                                                                 |
| ------------------------ | ---------------- | --------------------------------------------------------------------------------------------- |
| Mise en cache            | `LRUCache`    | [Mise en cache et chargement des images](docs/topics/caching-and-images.md)                   |
| Résilience               | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [Résilience réseau et mises à jour en temps réel](docs/topics/resilience-and-real-time.md)    |
| Pagination               | `Paginator`, `Page` | [Conception d’API et pagination](docs/topics/api-and-pagination.md)                           |
| Modifications hors ligne | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [Prise en charge du hors ligne et synchronisation](docs/topics/offline-and-sync.md)           |
| Synchronisation          | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [Prise en charge du hors ligne et synchronisation](docs/topics/offline-and-sync.md#conflicts) |
| Estimation               | `CapacityEstimate`, `ClientBudget` | [Un cadre pour le mobile system design](docs/framework.md#2-estimate)                         |

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Collez-la dans le champ de recherche en haut à droite de la fenêtre. Laissez **Dependency Rule** sur **Up to Next Major Version** à partir de `2.0.0`, puis cliquez sur **Add Package**. Dans la fenêtre suivante, choisissez la cible de votre application à côté de **MobileSystemDesign** et cliquez de nouveau sur **Add Package**.

**2. Importer le module**

```swift
import MobileSystemDesign
```

Placez cette ligne en haut du fichier Swift où vous utilisez le paquet.

**3. L’utiliser**

Dans une nouvelle application Xcode (**File › New › Project… › App**), remplacez tout le contenu de `ContentView.swift` par :

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

Appuyez sur **Run** (⌘R). L’application affiche une liste qui charge 20 lignes de plus chaque fois que vous arrivez à la fin, et s’arrête après la ligne 99. Remplacez `loadPage(after:)` par l’appel à votre API.

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

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

## Utilisation

Les exemples ci-dessous sont copiés depuis [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift). L’application d’exemple compile ce fichier, la suite de tests le compile et l’exécute, et `node scripts/check-readme-samples.mjs` vérifie que ce README montre le même code.

### Réessayer une requête et cesser d’appeler un serveur défaillant

Les échecs temporaires (délais dépassés, connexions perdues, `429`, `503`) sont réessayés avec un backoff exponentiel et du jitter ; cinq échecs d’affilée ouvrent le circuit breaker, et les appels échouent alors immédiatement pendant 30 secondes au lieu d’attendre les délais d’expiration.

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

### Conserver les modifications faites hors ligne jusqu’à leur envoi

Chaque modification est enregistrée dans un fichier avant que `enqueue` ne rende la main, envoyée de la plus ancienne à la plus récente lorsque vous faites un flush, et porte un UUID à utiliser comme clé d’idempotence de la requête.

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

### Mettre des images en cache en mémoire

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

### Résoudre une modification faite sur deux appareils

Une hybrid logical clock place une modification après tout ce que son appareil a déjà vu ; la modification la plus récente l’emporte donc, même si l’horloge de cet appareil est en retard.

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

### Estimer la charge d’une fonctionnalité

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

## Application d’exemple

[SystemDesignLab](Examples/SystemDesignLab) propose un laboratoire par brique de base. Son serveur s’exécute dans l’application : les laboratoires fonctionnent donc sans backend et s’affichent de la même façon à chaque exécution.

| Fil d’actualité                                                                                                                        | J’aime hors ligne                                                                                                                                 | Synchronisation                                                                                                                                                                       | Estimateur                                                                                                                                 |
| -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="Laboratoire du fil : sélecteur du mode du serveur, état du circuit breaker, nombre de requêtes et publications chargées" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="Laboratoire des J’aime hors ligne : interrupteur hors ligne, trois modifications en attente dans l’outbox et publications aimées" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="Laboratoire de synchronisation : titres du téléphone et de la tablette avec des horodatages hybrides, après la victoire de la modification plus récente de la tablette" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="Laboratoire de l’estimateur : données d’utilisation et débits de requêtes, bande passante et stockage qui en résultent" width="200"></picture> |

Ouvrez `Examples/SystemDesignLab/SystemDesignLab.xcodeproj`, choisissez un simulateur d’iPhone ou **My Mac**, puis appuyez sur **Run**. Les captures d’écran sont prises à partir de l’application en cours d’exécution par [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh).

## Documentation

La [référence de l’API](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/) est générée avec DocC à partir du code source et publiée à chaque modification de `main`.

## Guides

Le guide dans [`docs/`](docs) explique les questions de conception :

- [Un cadre pour le mobile system design](docs/framework.md) : les six étapes, les questions à poser et les signaux que recherchent les évaluateurs.
- Sujets : [Conception d’API et pagination](docs/topics/api-and-pagination.md) ·
  [Mise en cache et chargement des images](docs/topics/caching-and-images.md) ·
  [Prise en charge du hors ligne et synchronisation](docs/topics/offline-and-sync.md) ·
  [Résilience réseau et mises à jour en temps réel](docs/topics/resilience-and-real-time.md)
- Études de cas : [un fil de photos](docs/case-studies/news-feed.md) ·
  [une application de messagerie](docs/case-studies/chat-app.md) ·
  [le suivi en direct d’une course](docs/case-studies/ride-tracking.md) ·
  [les téléchargements de musique hors ligne](docs/case-studies/offline-music.md)

Les articles DocC expliquent le code :
[Prise en main](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[Construire une couche réseau résiliente](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[Concevoir un fil d’actualité offline-first](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[Estimer la capacité](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## Prérequis

| Plateforme      | Version minimale      |
| --------------- | --------------------- |
| iOS             | 17                    |
| macOS           | 14                    |
| Chaîne d’outils | Swift 6.2 · Xcode 26+ |

CI compile avec le Xcode par défaut de l’image de runner `macos-26` de GitHub. Le paquet est développé avec Xcode 27.

## Architecture

- `Sources/MobileSystemDesign/<Area>/` contient un dossier par domaine : `Caching`, `Resilience`, `Pagination`, `Offline`, `Sync` et `Estimation`. Le paquet n’a aucune dépendance autre que Foundation.
- L’état mutable partagé vit dans des actors (`CircuitBreaker`, `Paginator`, `Outbox`) ; les policies, les caches et les horloges sont des types valeur que vous conservez dans votre propre actor.
- Le temps est toujours injecté (une horloge, un paramètre `now` ou une fonction sleep) : les tests le font avancer à la main et n’attendent jamais.
- Les entrées qui peuvent venir de l’extérieur de l’application (configuration distante, en-têtes HTTP, fichiers stockés, horodatages d’autres appareils) sont bornées ou rejetées à la frontière du type ; les tests couvrent NaN, l’infini, `Int.max`, les valeurs négatives et le texte mal formé.
- CI exécute `swift test` sur macOS et `xcodebuild test` sur un simulateur d’iPhone, compile l’application d’exemple pour iOS et macOS, et publie la documentation DocC.

Pour exécuter les tests en local :

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Feuille de route

- Davantage d’études de cas : un fil de vidéos avec prefetching et un document collaboratif.
- Un utilitaire basé sur `NWPathMonitor` qui fait un flush d’un `Outbox` lorsque le réseau revient.
- Ajouter le paquet au Swift Package Index ; `.spi.yml` est déjà dans le dépôt.

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
