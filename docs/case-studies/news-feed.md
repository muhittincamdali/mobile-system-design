# Case study: a photo feed

"Design the client of an Instagram-style feed": a vertical list of posts with photos, likes
and comments, loaded as the user scrolls.

## 1. Requirements

**Functional**

- Show the home feed, newest relevant posts first, loading more on scroll.
- Like and unlike a post; show comment counts.
- Pull to refresh.

**Non-functional**

- First content quickly after launch, from the local store if available.
- Smooth scrolling with large images.
- Readable offline (the last loaded feed); likes made offline are not lost.
- Modest data use on cellular.

**Out of scope:** posting, stories, ranking on the server, comments thread.

## 2. Estimates

Assume 2 million daily users, each opening the feed several times and loading about 40 pages
of metadata (30 kB each) per day:

| Quantity                                                | Value                  |
| ------------------------------------------------------- | ---------------------- |
| Feed requests at peak (factor 3)                        | about 2,800 per second |
| Metadata per user per day                               | about 1.2 MB           |
| One photo decoded at full resolution (12 MP)            | 48 MB                  |
| One photo decoded for a full-width cell (1,170 px wide) | 4–7 MB, by aspect ratio |

The last two rows decide the image pipeline: decoding at full size would exhaust memory after
a few posts. The numbers come from
[`CapacityEstimate` and `ClientBudget`](../../Sources/MobileSystemDesign/Estimation/CapacityEstimate.swift).

## 3. High-level design

```text
FeedScreen ── FeedViewModel ── FeedRepository ─┬─ FeedAPI (cursor pages)
                                               ├─ FeedStore (database: posts, authors)
                                               └─ LikeOutbox ── LikeAPI
PostCell ── ImagePipeline ─┬─ memory cache (decoded, LRU)
                           ├─ disk cache (files)
                           └─ CDN (sized variants)
```

The screen observes `FeedStore`; the repository fills it from the API. The image pipeline is
separate from the data path and shared by every screen.

## 4. API and data

```http
GET /v1/feed?after=<cursor>&limit=20
→ { "items": [Post], "next_cursor": "…" }

PUT /v1/posts/{id}/like        Idempotency-Key: <uuid>
DELETE /v1/posts/{id}/like     Idempotency-Key: <uuid>
```

Each `Post` carries the author, text, counts, the viewer's like state and image variants:

```json
{
    "id": "p_918",
    "author": { "id": "u_7", "name": "Ada", "avatar": "…/u_7/96.jpg" },
    "images": [{ "url": "…/p_918/1080.jpg", "width": 1080, "height": 1350 }],
    "like_count": 42,
    "liked_by_viewer": false,
    "created_at": "2026-10-27T09:41:00Z"
}
```

The client picks the smallest variant at least as wide as the cell in pixels. Locally, posts
and authors are separate tables keyed by id, so an author's new avatar updates every post.

## 5. Deep dives

### Pagination

Cursor pagination, because new posts arrive at the top while the user scrolls. The client
deduplicates by post id, shares one request between concurrent "load more" triggers, and stops
on a repeated cursor; see [API design and pagination](../topics/api-and-pagination.md) and
[`Paginator`](../../Sources/MobileSystemDesign/Pagination/Paginator.swift). Prefetch the next
page when the row five posts before the end appears.

### Images

Request the sized variant, decode and downsample off the main thread, cache decoded bitmaps
by URL and size in an LRU memory cache whose cost is the decoded size, and cancel requests for
cells that scrolled away. See [Caching and image loading](../topics/caching-and-images.md).

### Likes

A tap updates the local store at once and enqueues the change in an
[outbox](../../Sources/MobileSystemDesign/Offline/Outbox.swift) with the key `like-<post id>`,
so repeated taps collapse into the final state. The outbox sends changes in order with their
idempotency keys and is flushed when the app becomes active or the network returns. A
permanent failure rolls the local like back.

### Refresh and freshness

On launch, show the stored feed and fetch the first page; insert new posts above with a "New
posts" pill instead of moving the content under the user's finger. Keep the stored feed for a
few days and a bounded number of posts.

### Failure handling

Retries with backoff and jitter for temporary errors; a circuit breaker per backend service;
on failure, keep showing stored and cached pages with a "showing saved posts" banner. The Feed
lab of the [example app](../../Examples) demonstrates all three.

## 6. Trade-offs and metrics

- Storing the feed costs disk space and a migration path, and gives instant launch and
  offline reading.
- Optimistic likes feel instant and need a rollback path.
- Measure: time to first post, scroll hitches, image memory, failed requests by status, outbox
  length, data used per session.
