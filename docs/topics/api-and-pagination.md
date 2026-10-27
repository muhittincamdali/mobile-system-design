# API design and pagination

How a mobile client should talk to its backend: request shapes, pagination, idempotency and
versioning.

## Design the API for the screen

A phone pays for every round trip in latency and battery. Prefer one request that returns
what a screen needs over several small ones, and keep payloads small:

- Return only the fields the client shows; send image URLs with sizes, not images.
- Support conditional requests (`ETag` and `If-None-Match`) so unchanged data costs a `304`
  without a body ([RFC 9110, section 13](https://www.rfc-editor.org/rfc/rfc9110#section-13)).
- Compress responses; `URLSession` and OkHttp decompress gzip transparently.
- Version the API (`/v2/feed` or a header) and keep old versions alive: users update apps
  slowly, and some never do.

## Offset or cursor pagination

|                                      | Offset (`?offset=40&limit=20`) | Cursor (`?after=c3VuZGF5&limit=20`) |
| ------------------------------------ | ------------------------------ | ----------------------------------- |
| New items at the top while scrolling | The next page repeats items    | Unaffected                          |
| Deleted items                        | The next page skips items      | Unaffected                          |
| Jump to page 7                       | Possible                       | Not possible                        |
| Server cost on deep pages            | Grows with the offset          | Constant with an index              |

Feeds, chats and notifications change while they are read, so they use cursors. A cursor is
an opaque string from the server, often an encoded `(timestamp, id)` of the last item. The
client never builds or parses it.

A page response carries the items and the cursor of the next page; no cursor means the end:

```json
{
    "items": [{ "id": "p_918", "author": "ada", "text": "…" }],
    "next_cursor": "eyJ0IjoxNzkzMDAwMDAwLCJpZCI6InBfOTE4In0"
}
```

### What the client must still handle

Even with cursors, a client sees duplicates (a retried request, a server bug), and a buggy
backend can return the same cursor forever. The package's
[`Paginator`](../../Sources/MobileSystemDesign/Pagination/Paginator.swift) handles these:

- concurrent "load more" calls share one request;
- items whose id is already listed are skipped;
- a repeated cursor, or several pages in a row with nothing new, end the list instead of
  looping;
- the list has a maximum size, so memory stays bounded in a long session;
- a refresh discards a page still loading for the old list.

### Prefetching

Start loading the next page before the user reaches the end: when the row a few screens
before the end appears, or with `UICollectionViewDataSourcePrefetching` and
`LazyColumn` visibility callbacks. Prefetch on Wi-Fi more aggressively than on cellular, and
not at all in Low Data Mode
([`NWPath.isConstrained`](https://developer.apple.com/documentation/network/nwpath/isconstrained)).

## Writes and idempotency

A request that timed out may have reached the server. If the client retries a `POST`, the
server may apply it twice: two comments, two payments. Make writes safe to repeat:

- Use `PUT` and `DELETE` with the full target state where possible — they are idempotent
  ([RFC 9110, section 9.2.2](https://www.rfc-editor.org/rfc/rfc9110#section-9.2.2)).
- For `POST`, send an `Idempotency-Key` header with a client-generated UUID and have the server
  remember the keys it has processed for a while. The package's
  [`Outbox`](../../Sources/MobileSystemDesign/Offline/Outbox.swift) gives each queued change a
  UUID for this.

## Errors

Return machine-readable errors with a stable code and a human message, and use status codes
the client can act on:

| Status              | Client action                                      |
| ------------------- | -------------------------------------------------- |
| `400`, `422`        | Show the error; do not retry                       |
| `401`               | Refresh the token once, then sign out              |
| `404`, `410`        | Remove the item locally                            |
| `409`               | Fetch the latest version and resolve the conflict  |
| `429`, `503`        | Retry after `Retry-After`, with backoff            |
| `500`, `502`, `504` | Retry with backoff a few times, then show an error |

[`RetryDecision.classify`](../../Sources/MobileSystemDesign/Resilience/RetryDecision.swift)
encodes the retry column.

## REST, GraphQL or gRPC

- **REST** is simple, cacheable by HTTP caches and CDNs, and well supported everywhere.
- **GraphQL** lets each screen ask for exactly the fields it needs, which helps when many
  clients and screens share one backend; HTTP caching is harder, so clients cache normalized
  results instead.
- **gRPC** gives typed contracts and efficient binary encoding; it needs HTTP/2 and is less
  convenient to inspect.

Any of them works in an interview if you explain the trade-off for the product at hand.
