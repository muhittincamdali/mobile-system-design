# Network resilience and real-time updates

How a client survives an unreliable network, and how it receives updates as they happen.

## Mobile networks fail in specific ways

- The connection drops in lifts and tunnels, and changes between Wi-Fi and cellular.
- Latency varies by orders of magnitude between a good Wi-Fi network and a weak cellular one.
- Captive portals answer every request with a login page.
- The OS suspends the app shortly after it goes to the background, ending open sockets.
- Low Data Mode and Data Saver ask apps to use less data.

Design for these as normal conditions.

## Timeouts

Set a timeout per request type, shorter for interactive requests than for uploads. On iOS,
[`URLSessionConfiguration.waitsForConnectivity`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/waitsforconnectivity)
lets a request wait for a network instead of failing at once — useful for background
transfers, wrong for a screen showing a spinner.

## Retries

Retry only temporary failures (timeouts, lost connections, `408`, `429`, `5xx`) and only
requests that are safe to repeat. Wait longer after each attempt, and add randomness
(**jitter**) so clients that failed together do not retry together
([Exponential backoff and jitter, AWS Architecture Blog](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)).
Honour `Retry-After`, but give up when it is longer than the user will wait.

[`RetryPolicy` and `Retrier`](../../Sources/MobileSystemDesign/Resilience/Retrier.swift)
implement this, with configuration values clamped so a bad remote config cannot produce an
infinite or negative wait.

## Circuit breaker

When a service is down, retries from every client add load and every user waits for
timeouts. A circuit breaker counts consecutive failures; past a threshold it **opens** and
fails calls at once, then lets a single probe through after a pause. Use one breaker per
dependency. See
[`CircuitBreaker`](../../Sources/MobileSystemDesign/Resilience/CircuitBreaker.swift).

## Client-side rate limiting

Search-as-you-type, scroll-triggered analytics and repeated pull-to-refresh can flood a
backend. Debounce input, and cap the rate with a token bucket
([`TokenBucket`](../../Sources/MobileSystemDesign/Resilience/TokenBucket.swift)).

## Real-time updates

| Mechanism                                                      | Direction                         | While app is | Use for                            |
| -------------------------------------------------------------- | --------------------------------- | ------------ | ---------------------------------- |
| Polling                                                        | Client asks                       | Foreground   | Rarely changing data; simplest     |
| Long polling                                                   | Server answers when there is news | Foreground   | Fallback when sockets are blocked  |
| Server-sent events                                             | Server → client                   | Foreground   | Feeds, scores, notifications       |
| WebSocket ([RFC 6455](https://www.rfc-editor.org/rfc/rfc6455)) | Both ways                         | Foreground   | Chat, live location, collaboration |
| Push notifications                                             | Server → device                   | Any state    | Wake the user or the app           |

A foreground connection does not survive in the background: iOS suspends the app, and
Android restricts background network access. Use push notifications
([APNs](https://developer.apple.com/documentation/usernotifications),
[Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)) to reach a
backgrounded app, and treat a push as a hint to sync, not as the data itself: pushes can be
delayed, coalesced or dropped.

### Keeping a socket healthy

- **Heartbeats.** Send a ping every 20–60 seconds; missing pongs mean the connection is dead
  even when the OS has not noticed.
- **Reconnect with backoff and jitter**, and reset the backoff after a connection that lasted.
- **Resume, don't restart.** After reconnecting, send the id of the last event received so the
  server replays what was missed, or pull the changes since the last sync token.
- **Order and duplicates.** Give events a sequence number per conversation or entity; buffer
  out-of-order events and ignore ones already applied.

## What to say in an interview

- Which failures are retried, how often, and how the user sees the rest.
- How the app avoids making an outage worse.
- Which real-time mechanism fits the product in the foreground and in the background.
- How the client catches up after being offline and avoids applying an event twice.
