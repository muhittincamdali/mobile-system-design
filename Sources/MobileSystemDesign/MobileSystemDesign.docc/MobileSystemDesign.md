# ``MobileSystemDesign``

Tested building blocks for the client side of a mobile system: caching, retries, circuit
breaking, rate limiting, pagination, an offline outbox, conflict-free sync and capacity
estimates.

## Overview

Mobile system design interviews and design reviews keep returning to the same client-side
questions. How does the feed page without duplicates? What happens to a "like" made in a
tunnel? Who wins when two devices edit the same title? How many requests per second will the
launch bring? This package answers each one with a small, dependency-free type that you can
read in one sitting, use in an app, and point to in a design document.

Every type is safe to feed with bad input — values from remote configuration, server
headers or a corrupted file are clamped or rejected instead of trapping — and each one is
covered by Swift Testing tests that run on macOS and an iOS simulator.

The repository's [guide](https://github.com/muhittincamdali/mobile-system-design/tree/main/docs)
explains the design questions; these pages explain the code.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:ResilientNetworking>
- <doc:OfflineFirstFeeds>
- <doc:EstimatingCapacity>

### Caching

- ``LRUCache``

### Resilience

- ``RetryPolicy``
- ``Retrier``
- ``RetryDecision``
- ``RetryAfter``
- ``HTTPStatusError``
- ``CircuitBreaker``
- ``CircuitBreakerError``
- ``TokenBucket``

### Pagination

- ``Paginator``
- ``Page``

### Offline changes

- ``Outbox``
- ``OutboxEntry``
- ``OutboxFlushReport``
- ``OutboxError``
- ``OutboxStore``
- ``OutboxSnapshot``
- ``FileOutboxStore``
- ``InMemoryOutboxStore``

### Sync

- ``HybridLogicalClock``
- ``HybridTimestamp``
- ``LWWRegister``

### Estimation

- ``CapacityEstimate``
- ``ClientBudget``
