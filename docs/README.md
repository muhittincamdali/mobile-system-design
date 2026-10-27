# The guide

A guide to designing the client side of mobile systems, for interviews and for real design
reviews. Each page explains a design question; where code helps, it links to the tested
implementation in the [`MobileSystemDesign`](../Sources/MobileSystemDesign) package.

## Start here

- [A framework for mobile system design](framework.md): the six steps of a 45–60 minute
  session, what to ask, and what reviewers look for.

## Topics

| Page                                                                           | Covers                                                                                      | Package types                                 |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- | --------------------------------------------- |
| [API design and pagination](topics/api-and-pagination.md)                      | Request shapes, cursor vs offset, prefetching, idempotency, errors, REST vs GraphQL vs gRPC | `Paginator`, `RetryDecision`                  |
| [Caching and image loading](topics/caching-and-images.md)                      | Cache layers, invalidation, eviction, memory pressure, the image pipeline                   | `LRUCache`, `ClientBudget`                    |
| [Offline support and sync](topics/offline-and-sync.md)                         | Levels of offline support, the outbox, pulling changes, conflicts, hybrid logical clocks    | `Outbox`, `HybridLogicalClock`, `LWWRegister` |
| [Network resilience and real-time updates](topics/resilience-and-real-time.md) | Timeouts, retries with jitter, circuit breakers, rate limiting, sockets, push               | `Retrier`, `CircuitBreaker`, `TokenBucket`    |

## Case studies

Each case study follows the [framework](framework.md): requirements, estimates, high-level
design, API and data, deep dives, trade-offs and metrics.

| Case study                                               | Deep dives                                                            |
| -------------------------------------------------------- | --------------------------------------------------------------------- |
| [A photo feed](case-studies/news-feed.md)                | Pagination, image memory, optimistic likes, refresh                   |
| [A chat app](case-studies/chat-app.md)                   | Sending exactly once, ordering, socket lifecycle, background delivery |
| [Live ride tracking](case-studies/ride-tracking.md)      | Idempotent requests, location sampling, smooth markers                |
| [Offline music downloads](case-studies/offline-music.md) | Download state machine, background transfer, storage, licenses        |

## A study path

1. Read the [framework](framework.md) and practise the first two steps on any app on your
   phone.
2. Read the four topic pages; run the matching lab of the [example app](../Examples) and
   change its settings — make the server flaky, go offline, skew a clock.
3. Work through a case study on paper before reading it, then compare.
4. Read the package source of one building block and its tests; the edge cases in the tests
   are good interview material.
