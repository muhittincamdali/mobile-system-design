<!-- i18n-source: README.md@d03b4b12f1062ccc5bd8c9eece9ab260ab980056 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

Руководство по проектированию клиентской части мобильных приложений (ленты, чаты, отслеживание в реальном времени, офлайн-медиа) вместе с пакетом на Swift, в котором реализованы его строительные блоки. Оно предназначено для инженеров, которые готовятся к собеседованиям по mobile system design, и для команд, пишущих проектную документацию. Руководство разбирает каждый вопрос проектирования, а пакет даёт ответ в виде небольших протестированных типов Swift без зависимостей. Так вы сможете прочитать код, стоящий за каждой рекомендацией, запустить его в демонстрационном приложении и использовать в своём проекте.

## Основные возможности

- **Методика и четыре разбора примеров** — структура из шести шагов для сессии на 45–60 минут, применённая к ленте фотографий, чат-приложению, отслеживанию поездки в реальном времени и загрузке музыки для офлайн-прослушивания.
- **Строительные блоки, которые можно запустить** — LRU cache, повторные попытки с backoff и `Retry-After`, circuit breaker, token bucket, paginator на основе cursor, постоянный outbox, hybrid logical clock и last-writer-wins register, оценка ёмкости.
- **Рассчитано на некорректные данные** — значения из удалённой конфигурации, заголовков сервера и сохранённых файлов ограничиваются или отклоняются: нет аварийного завершения из-за NaN, переполнения или неправильного заголовка, нет бесконечного цикла при сервере, который повторяет свой cursor, а у каждой очереди и каждого кэша есть предел размера.
- **Языковой режим Swift 6** — actor для общего состояния, типы `Sendable`, ни одного предупреждения.
- **Протестировано** — 117 тестов Swift Testing, которые выполняются на macOS и в симуляторе iPhone, включая примеры из README ниже.
- **Демонстрационное приложение** — [SystemDesignLab](Examples/SystemDesignLab) запускает каждый блок на имитируемом сервере, который можно сделать нестабильным, отключить или лишить связи.

### Что входит в пакет

| Область               | Типы             | Страница руководства                                                                               |
| --------------------- | ---------------- | -------------------------------------------------------------------------------------------------- |
| Кэширование           | `LRUCache`    | [Кэширование и загрузка изображений](docs/topics/caching-and-images.md)                            |
| Отказоустойчивость    | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [Отказоустойчивость сети и обновления в реальном времени](docs/topics/resilience-and-real-time.md) |
| Постраничная загрузка | `Paginator`, `Page` | [Проектирование API и постраничная загрузка](docs/topics/api-and-pagination.md)                    |
| Изменения офлайн      | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [Офлайн-режим и синхронизация](docs/topics/offline-and-sync.md)                                    |
| Синхронизация         | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [Офлайн-режим и синхронизация](docs/topics/offline-and-sync.md#conflicts)                          |
| Оценка                | `CapacityEstimate`, `ClientBudget` | [Подход к mobile system design](docs/framework.md#2-estimate)                                      |

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Вставьте его в поле поиска в правом верхнем углу окна. Оставьте **Dependency Rule** в положении **Up to Next Major Version** начиная с `2.0.0` и нажмите **Add Package**. В следующем окне выберите целевой модуль вашего приложения рядом с **MobileSystemDesign** и ещё раз нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import MobileSystemDesign
```

Поместите эту строку в начало файла Swift, где вы используете пакет.

**3. Используйте**

В новом приложении Xcode (**File › New › Project… › App**) замените всё содержимое `ContentView.swift` на:

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

Нажмите **Run** (⌘R). Приложение показывает список, который подгружает ещё 20 строк каждый раз, когда вы доходите до конца, и останавливается после строки 99. Замените `loadPage(after:)` вызовом вашего API.

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

## Использование

Приведённые ниже примеры скопированы из файла [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift). Демонстрационное приложение компилирует этот файл, набор тестов компилирует и запускает его, а `node scripts/check-readme-samples.mjs` проверяет, что в этом README показан тот же код.

### Повторите запрос и перестаньте обращаться к сбойному серверу

Временные сбои (тайм-ауты, потеря соединения, `429`, `503`) обрабатываются повторными попытками с экспоненциальным backoff и jitter; пять сбоев подряд размыкают circuit breaker, и тогда вызовы сразу завершаются ошибкой в течение 30 секунд, не дожидаясь тайм-аутов.

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

### Сохраняйте изменения, сделанные офлайн, пока они не будут отправлены

Каждое изменение сохраняется в файл до того, как `enqueue` вернёт управление, при flush отправляется начиная с самого старого и несёт UUID, который можно использовать как ключ идемпотентности запроса.

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

### Кэшируйте изображения в памяти

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

### Разрешите конфликт правок, сделанных на двух устройствах

Hybrid logical clock ставит правку после всего, что видело её устройство, поэтому более поздняя правка побеждает, даже если часы этого устройства отстают.

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

### Оцените нагрузку функции

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

## Демонстрационное приложение

В [SystemDesignLab](Examples/SystemDesignLab) есть по одной лаборатории на каждый строительный блок. Сервер работает внутри приложения, поэтому лаборатории не требуют бэкенда и при каждом запуске выглядят одинаково.

| Лента                                                                                                                      | Лайки офлайн                                                                                                                       | Синхронизация                                                                                                                                     | Калькулятор оценки                                                                                                                              |
| -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="Лаборатория ленты: выбор режима сервера, состояние circuit breaker, число запросов и загруженные публикации" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="Лаборатория лайков офлайн: переключатель офлайн-режима, три изменения, ожидающие в outbox, и публикации с лайками" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="Лаборатория синхронизации: заголовки на телефоне и планшете с hybrid-метками времени после победы более поздней правки на планшете" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="Лаборатория оценки: входные данные об использовании и полученные частота запросов, пропускная способность и объём хранилища" width="200"></picture> |

Откройте `Examples/SystemDesignLab/SystemDesignLab.xcodeproj`, выберите симулятор iPhone или **My Mac** и нажмите **Run**. Скриншоты делает скрипт [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) в работающем приложении.

## Документация

[Справочник API](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/) создаётся из исходного кода с помощью DocC и публикуется при каждом изменении в `main`.

## Руководства

Руководство в папке [`docs/`](docs) разбирает вопросы проектирования:

- [Подход к mobile system design](docs/framework.md) — шесть шагов, вопросы, которые стоит задавать, и признаки, на которые обращают внимание рецензенты.
- Темы: [Проектирование API и постраничная загрузка](docs/topics/api-and-pagination.md) ·
  [Кэширование и загрузка изображений](docs/topics/caching-and-images.md) ·
  [Офлайн-режим и синхронизация](docs/topics/offline-and-sync.md) ·
  [Отказоустойчивость сети и обновления в реальном времени](docs/topics/resilience-and-real-time.md)
- Разборы примеров: [лента фотографий](docs/case-studies/news-feed.md) ·
  [чат-приложение](docs/case-studies/chat-app.md) ·
  [отслеживание поездки в реальном времени](docs/case-studies/ride-tracking.md) ·
  [загрузка музыки для офлайн-прослушивания](docs/case-studies/offline-music.md)

Статьи DocC объясняют код:
[Начало работы](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[Как построить отказоустойчивый сетевой слой](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[Как спроектировать ленту по принципу offline-first](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[Оценка ёмкости](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## Требования

| Платформа   | Минимальная версия    |
| ----------- | --------------------- |
| iOS         | 17                    |
| macOS       | 14                    |
| Инструменты | Swift 6.2 · Xcode 26+ |

CI собирает проект в Xcode по умолчанию из образа runner `macos-26` на GitHub. Пакет разрабатывается в Xcode 27.

## Архитектура

- В `Sources/MobileSystemDesign/<Area>/` лежит по одной папке на каждую область: `Caching`, `Resilience`, `Pagination`, `Offline`, `Sync` и `Estimation`. У пакета нет зависимостей, кроме Foundation.
- Общее изменяемое состояние хранится в actor (`CircuitBreaker`, `Paginator`, `Outbox`); policy, кэши и часы — это типы-значения, которые вы держите внутри собственного actor.
- Время всегда передаётся извне (часы, параметр `now` или функция sleep), поэтому тесты управляют им вручную и никогда не ждут.
- Входные данные, которые могут прийти извне приложения (удалённая конфигурация, заголовки HTTP, сохранённые файлы, метки времени с других устройств), ограничиваются или отклоняются на границе типа; тесты охватывают NaN, бесконечность, `Int.max`, отрицательные значения и некорректный текст.
- CI запускает `swift test` на macOS и `xcodebuild test` в симуляторе iPhone, собирает демонстрационное приложение для iOS и macOS и публикует документацию DocC.

Чтобы запустить тесты локально:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## План развития

- Новые разборы примеров: видеолента с prefetching и документ для совместной работы.
- Вспомогательный компонент на основе `NWPathMonitor`, который делает flush для `Outbox`, когда сеть возвращается.
- Добавить пакет в Swift Package Index; файл `.spi.yml` уже есть в репозитории.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
