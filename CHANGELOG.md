# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-27

The repository becomes a guide plus a tested Swift package. Version 1.0.0 was documentation
only; its pages were replaced, so this is a major version.

### Added

- `MobileSystemDesign`, a Swift package for iOS 17+ and macOS 14+ with no dependencies, built
  in the Swift 6 language mode:
    - `LRUCache`: count and cost limits, time to live, `removeExpired(now:)`, `trim(toCost:)`.
    - `RetryPolicy`, `Retrier`, `RetryDecision`, `RetryAfter` and `HTTPStatusError`: exponential
      backoff with none, full or equal jitter; `Retry-After` in seconds or any of the three HTTP
      date formats, capped at one day; retries stop at a permanent error, on cancellation, or when
      the server asks for a wait above the policy's maximum.
    - `CircuitBreaker`: closed, open and half-open states with a probe limit; results of calls
      from before a state change are ignored.
    - `TokenBucket`: client-side rate limiting with bursts.
    - `Paginator` and `Page`: cursor pagination that shares concurrent requests, skips duplicate
      items, ends on a repeated cursor or on pages without progress, and has an item limit.
    - `Outbox`, `FileOutboxStore` and `InMemoryOutboxStore`: a persistent, ordered queue of
      offline changes with idempotency keys, coalescing, backoff, dead letters and size limits.
    - `HybridLogicalClock`, `HybridTimestamp` and `LWWRegister`: conflict resolution that does
      not depend on device clocks, with drift rejection.
    - `CapacityEstimate` and `ClientBudget`: request rates, bandwidth, storage and decoded image
      sizes.
- Inputs from remote configuration, HTTP headers, files and other devices are clamped or
  rejected: no trap on NaN, infinity, integer overflow or malformed text.
- 109 Swift Testing tests, run on macOS and an iPhone simulator, including the README samples.
- DocC documentation with four articles: getting started, a resilient network layer, an
  offline-first feed, and capacity estimates.
- `Examples/SystemDesignLab`, an iOS and macOS app with one lab per building block and a
  simulated server; `scripts/capture-screenshots.sh` takes the README screenshots from it.
- `scripts/check-readme-samples.mjs`, which checks that the README shows the compiled samples.
- The guide: a framework for 45–60 minute sessions, four topic pages (API design and
  pagination, caching and images, offline and sync, resilience and real time) and four case
  studies (photo feed, chat app, live ride tracking, offline music downloads).
- CI through the shared workflows: package tests on macOS and iOS, DocC on GitHub Pages, the
  example app build, link check, hygiene and README translation checks.

### Removed

- The generated case studies and pattern pages of 1.0.0 (`docs/case-studies/*.md`,
  `docs/patterns/*.md`). Their code listings were never compiled and their scale figures had
  no sources. They remain in the Git history.
- `scripts/blueprint_generator.py`, which printed fixed text.
- Repository copies of the code of conduct, security policy and issue templates, which came
  from another project; the account-wide versions in `muhittincamdali/.github` apply.

## [1.0.0] - 2026-02-03

### Added

- First version of the mobile system design guide.

[Unreleased]: https://github.com/muhittincamdali/mobile-system-design/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/mobile-system-design/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/mobile-system-design/releases/tag/v1.0.0
