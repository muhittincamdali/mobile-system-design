# Building a resilient network layer

Retry what is worth retrying, stop calling a server that is down, and keep the client from
flooding it.

## Overview

A phone loses its connection in lifts, tunnels and handovers between cell towers, and a
server under load answers with `503`. A resilient client does three things:

1. **Retries temporary failures** with growing, randomized waits — ``Retrier`` and
   ``RetryPolicy``.
2. **Fails fast while a dependency is down** instead of waiting for every timeout —
   ``CircuitBreaker``.
3. **Limits its own request rate** for chatty features such as search-as-you-type —
   ``TokenBucket``.

### Decide what to retry

``RetryDecision/classify(_:)`` is the default classifier. It retries `408`, `429`, `500`,
`502`, `503` and `504`, and `URLError` codes that describe a temporary connection problem such
as `.timedOut` and `.networkConnectionLost`. It never retries cancellation, and it treats other
`4xx` answers as permanent: the same request would get the same answer.

Only retry requests that are safe to repeat. `GET`, `PUT` and `DELETE` are idempotent by
definition ([RFC 9110, section 9.2.2](https://www.rfc-editor.org/rfc/rfc9110#section-9.2.2));
a `POST` is safe to repeat only when it carries an idempotency key that the server
deduplicates — ``Outbox`` gives every entry one.

Turn a response into an error with ``HTTPStatusError/init(response:now:)``. It reads the
`Retry-After` header with ``RetryAfter/parse(_:now:)``, which accepts seconds and the three HTTP
date formats and caps the wait at one day:

```swift
let (data, response) = try await session.data(for: request)
if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
    throw HTTPStatusError(response: http)
}
```

### Back off with jitter

``RetryPolicy`` waits `initialDelay × multiplier^(attempt − 1)`, capped at `maxDelay`. Without
randomness, every phone that lost the connection at the same moment would retry at the same
moment and hit the recovering server together. ``RetryPolicy/Jitter/full`` picks a random
wait between zero and the computed delay, which spreads retries the most;
``RetryPolicy/Jitter/equal`` keeps at least half of it.

```swift
let policy = RetryPolicy(maxAttempts: 4, initialDelay: .milliseconds(250), maxDelay: .seconds(8))
let retrier = Retrier(policy: policy)
let feed = try await retrier.run { attempt in
    try await api.feed()
}
```

When the server sends `Retry-After`, the retrier waits that long instead — unless it is
longer than `maxDelay`. Then it gives up and returns the error, because keeping a user
waiting for minutes behind a spinner is worse than showing the error and a retry button.

Policies often arrive through remote configuration, so ``RetryPolicy/init(maxAttempts:initialDelay:multiplier:maxDelay:jitter:)``
clamps every value: attempts stay between 1 and ``RetryPolicy/attemptLimit``, negative delays
become zero, and a multiplier below 1 becomes 1. ``RetryPolicy/delay(afterAttempt:randomUnit:)``
cannot produce an infinite or NaN delay, even for an attempt number of `Int.max`.

### Open the circuit

Retries help with short blips; they make a long outage worse. ``CircuitBreaker`` counts
consecutive failures. At ``CircuitBreaker/Configuration/failureThreshold`` it opens, and calls
fail at once with ``CircuitBreakerError/open(retryAfter:)`` for
``CircuitBreaker/Configuration/openDuration``. Then a single probe call goes through: success
closes the breaker, failure opens it again.

Put the breaker inside the retrier, so an open breaker ends the retries at once
(``RetryDecision/classify(_:)`` does not retry ``CircuitBreakerError``):

```swift
let breaker = CircuitBreaker(configuration: .init(failureThreshold: 5, openDuration: .seconds(30)))
let profile = try await retrier.run { _ in
    try await breaker.run { try await api.profile() }
}
```

Use one breaker per dependency — one for the feed service, one for the image CDN — so an
outage of one does not block the other. By default, cancellation and `4xx` answers other than
`429` do not count as failures; pass `countsAsFailure` to change that.

### Limit your own rate

``TokenBucket`` lets a burst of up to `capacity` requests through, then `refillPerSecond` on
average. It is a value type: keep it in the actor or view model that owns the feature.

```swift
var searchLimiter = TokenBucket(capacity: 3, refillPerSecond: 2)

func queryChanged(_ text: String) async {
    guard searchLimiter.tryConsume() else { return } // drop this keystroke
    await search(text)
}
```

``TokenBucket/timeUntilAvailable(_:at:)`` tells how long to wait instead of dropping, and
returns `nil` when a request can never be served.

### Test without waiting

Every type takes its clock and its sleep function as parameters. Tests pass a manual clock and
a sleep that only records the requested wait, so retry and breaker tests run instantly and
check exact durations:

```swift
let retrier = Retrier(policy: policy, sleep: { waits.append($0) }, random: { 0.5 })
```
