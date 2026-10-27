<!-- i18n-source: README.md@e8cdb614e0a73e05a8def8ea58e5820d77a216c2 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/banner-light.svg" alt="Mobile System Design: A mobile system design guide with tested Swift building blocks: caching, retries, pagination, offline sync."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/mobile-system-design/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/mobile-system-design/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/mobile-system-design/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

Um guia para projetar o lado cliente de apps móveis (feeds, chat, rastreamento ao vivo, mídia offline), junto com um pacote Swift que implementa seus blocos de construção. Ele é voltado a engenheiros que se preparam para entrevistas de mobile system design e a equipes que escrevem documentos de design. O guia explica cada pergunta de design; o pacote dá a resposta na forma de tipos Swift pequenos, sem dependências e com testes, para que você possa ler o código por trás de cada recomendação, executá-lo no app de exemplo e usá-lo no seu.

## Destaques

- **Um framework e quatro estudos de caso**: uma estrutura de seis passos para uma sessão de 45 a 60 minutos, aplicada a um feed de fotos, a um app de chat, ao rastreamento ao vivo de uma corrida e a downloads de música offline.
- **Blocos de construção que você pode executar**: LRU cache, retry com backoff e `Retry-After`, circuit breaker, token bucket, paginator baseado em cursor, outbox persistente, hybrid logical clock e last-writer-wins register, estimativas de capacidade.
- **Feito para entradas inválidas**: valores vindos da configuração remota, de cabeçalhos do servidor e de arquivos armazenados são limitados ou rejeitados. Não há travamento com NaN, overflow ou um cabeçalho malformado, nem loop infinito com um servidor que repete o cursor, e toda fila e todo cache tem um limite de tamanho.
- **Modo de linguagem Swift 6**: actors para o estado compartilhado, tipos `Sendable`, sem avisos.
- **Testado**: 111 testes com Swift Testing, executados no macOS e em um simulador de iPhone, incluindo os exemplos do README abaixo.
- **Um app de exemplo**: o [SystemDesignLab](Examples/SystemDesignLab) executa cada bloco de construção contra um servidor simulado que você pode deixar instável, derrubar ou desconectar.

### O que está incluído

| Área             | Tipos            | Página do guia                                                                              |
| ---------------- | ---------------- | ------------------------------------------------------------------------------------------- |
| Cache            | `LRUCache`    | [Cache e carregamento de imagens](docs/topics/caching-and-images.md)                        |
| Resiliência      | `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter`, `HTTPStatusError`, `CircuitBreaker`, `TokenBucket` | [Resiliência de rede e atualizações em tempo real](docs/topics/resilience-and-real-time.md) |
| Paginação        | `Paginator`, `Page` | [Design de API e paginação](docs/topics/api-and-pagination.md)                              |
| Mudanças offline | `Outbox`, `FileOutboxStore`, `InMemoryOutboxStore`    | [Suporte offline e sincronização](docs/topics/offline-and-sync.md)                          |
| Sincronização    | `HybridLogicalClock`, `HybridTimestamp`, `LWWRegister`       | [Suporte offline e sincronização](docs/topics/offline-and-sync.md#conflicts)                |
| Estimativa       | `CapacityEstimate`, `ClientBudget` | [Um framework para mobile system design](docs/framework.md#2-estimate)                      |

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Cole-a no campo de busca no canto superior direito da janela. Deixe **Dependency Rule** em **Up to Next Major Version** a partir de `2.0.0` e clique em **Add Package**. Na janela seguinte, escolha o target do seu app ao lado de **MobileSystemDesign** e clique em **Add Package** novamente.

**2. Importe o módulo**

```swift
import MobileSystemDesign
```

Coloque esta linha no topo do arquivo Swift em que você usa o pacote.

**3. Use**

Em um novo app do Xcode (**File › New › Project… › App**), substitua todo o conteúdo de `ContentView.swift` por:

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

Pressione **Run** (⌘R). O app mostra uma lista que carrega mais 20 linhas cada vez que você rola até o fim e para depois da linha 99. Substitua `loadPage(after:)` pela chamada à sua API.

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/mobile-system-design.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

## Uso

Os exemplos abaixo foram copiados de [`Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift`](Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift). O app de exemplo compila esse arquivo, a suíte de testes o compila e o executa, e `node scripts/check-readme-samples.mjs` verifica se este README mostra o mesmo código.

### Repita uma requisição e pare de chamar um servidor com falhas

Falhas temporárias (timeouts, conexões perdidas, `429`, `503`) são repetidas com backoff exponencial e jitter; cinco falhas seguidas abrem o circuit breaker, e as chamadas passam a falhar na hora por 30 segundos, em vez de esperar pelos timeouts.

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

### Guarde as mudanças feitas offline até que sejam enviadas

Cada mudança é salva em um arquivo antes de `enqueue` retornar, é enviada começando pela mais antiga quando você faz o flush e leva um UUID para usar como chave de idempotência da requisição.

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

### Armazene imagens em cache na memória

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

### Resolva uma edição feita em dois dispositivos

Um hybrid logical clock ordena uma edição depois de tudo que o dispositivo dela já viu, de modo que a edição mais recente vence mesmo quando o relógio desse dispositivo está atrasado.

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

### Estime a carga de uma funcionalidade

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

## App de exemplo

O [SystemDesignLab](Examples/SystemDesignLab) tem um laboratório para cada bloco de construção. O servidor roda dentro do app, então os laboratórios funcionam sem backend e têm a mesma aparência a cada execução.

| Feed                                                                                                                                            | Curtidas offline                                                                                                                  | Sincronização                                                                                                                                         | Estimador                                                                                                                              |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-feed-dark.png"><img src="docs/images/lab-feed-light.png" alt="Laboratório do feed: seletor do modo do servidor, estado do circuit breaker, contagem de requisições e as publicações carregadas" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-outbox-dark.png"><img src="docs/images/lab-outbox-light.png" alt="Laboratório de curtidas offline: chave de modo offline, três mudanças esperando no outbox e publicações curtidas" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-sync-dark.png"><img src="docs/images/lab-sync-light.png" alt="Laboratório de sincronização: títulos do celular e do tablet com timestamps híbridos depois que a edição mais recente do tablet venceu" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/lab-estimator-dark.png"><img src="docs/images/lab-estimator-light.png" alt="Laboratório do estimador: dados de uso e as taxas de requisições, a largura de banda e o armazenamento resultantes" width="200"></picture> |

Abra `Examples/SystemDesignLab/SystemDesignLab.xcodeproj`, escolha um simulador de iPhone ou **My Mac** e pressione **Run**. As capturas de tela são feitas pelo [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) a partir do app em execução.

## Documentação

A [referência da API](https://muhittincamdali.github.io/mobile-system-design/documentation/mobilesystemdesign/) é gerada com DocC a partir do código-fonte e publicada a cada mudança em `main`.

## Guias

O guia em [`docs/`](docs) explica as perguntas de design:

- [Um framework para mobile system design](docs/framework.md): os seis passos, as perguntas a fazer e os sinais que os avaliadores procuram.
- Tópicos: [Design de API e paginação](docs/topics/api-and-pagination.md) ·
  [Cache e carregamento de imagens](docs/topics/caching-and-images.md) ·
  [Suporte offline e sincronização](docs/topics/offline-and-sync.md) ·
  [Resiliência de rede e atualizações em tempo real](docs/topics/resilience-and-real-time.md)
- Estudos de caso: [um feed de fotos](docs/case-studies/news-feed.md) ·
  [um app de chat](docs/case-studies/chat-app.md) ·
  [rastreamento ao vivo de uma corrida](docs/case-studies/ride-tracking.md) ·
  [downloads de música offline](docs/case-studies/offline-music.md)

Os artigos do DocC explicam o código:
[Primeiros passos](Sources/MobileSystemDesign/MobileSystemDesign.docc/GettingStarted.md) ·
[Como construir uma camada de rede resiliente](Sources/MobileSystemDesign/MobileSystemDesign.docc/ResilientNetworking.md) ·
[Como projetar um feed offline-first](Sources/MobileSystemDesign/MobileSystemDesign.docc/OfflineFirstFeeds.md) ·
[Como estimar a capacidade](Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)

## Requisitos

| Plataforma  | Versão mínima         |
| ----------- | --------------------- |
| iOS         | 17                    |
| macOS       | 14                    |
| Ferramentas | Swift 6.2 · Xcode 26+ |

O CI compila com o Xcode padrão da imagem de runner `macos-26` do GitHub. O pacote é desenvolvido com o Xcode 27.

## Arquitetura

- `Sources/MobileSystemDesign/<Area>/` tem uma pasta por área: `Caching`, `Resilience`, `Pagination`, `Offline`, `Sync` e `Estimation`. O pacote não tem dependências além do Foundation.
- O estado mutável compartilhado fica em actors (`CircuitBreaker`, `Paginator`, `Outbox`); policies, caches e relógios são tipos por valor que você mantém dentro do seu próprio actor.
- O tempo é sempre injetado (um relógio, um parâmetro `now` ou uma função sleep), então os testes o controlam manualmente e nunca esperam.
- Entradas que podem vir de fora do app (configuração remota, cabeçalhos HTTP, arquivos armazenados, timestamps de outros dispositivos) são limitadas ou rejeitadas na fronteira do tipo; os testes cobrem NaN, infinito, `Int.max`, valores negativos e texto malformado.
- O CI executa `swift test` no macOS e `xcodebuild test` em um simulador de iPhone, compila o app de exemplo para iOS e macOS e publica a documentação do DocC.

Para executar os testes localmente:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileSystemDesign \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Roteiro

- Mais estudos de caso: um feed de vídeo com prefetching e um documento colaborativo.
- Um helper baseado em `NWPathMonitor` que faz o flush de um `Outbox` quando a rede volta.
- Adicionar o pacote ao Swift Package Index; o `.spi.yml` já está no repositório.

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](https://github.com/muhittincamdali/mobile-system-design/blob/main/CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
