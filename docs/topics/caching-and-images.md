# Caching and image loading

Where a mobile app keeps data it already downloaded, how long it trusts it, and how to load
images without running out of memory.

## Cache layers

| Layer      | Holds                         | Survives                                           | Typical size                       |
| ---------- | ----------------------------- | -------------------------------------------------- | ---------------------------------- |
| Memory     | Decoded images, parsed models | Until the app is suspended or memory runs low      | Tens of MB                         |
| Disk       | Response bodies, image files  | Until the cache is trimmed or the OS clears caches | Hundreds of MB                     |
| HTTP cache | Responses with cache headers  | Like disk                                          | Set in `URLCache` / OkHttp `Cache` |
| Database   | The app's data model          | Until the app deletes it                           | As needed                          |

Use the database as the source of truth for content the user expects to see offline (their
feed, their messages). Use caches for data you can download again.

## Invalidation

Every cached item needs a rule for when it is stale:

- **Time to live.** Simple and predictable; good for feeds and catalogs.
- **Validation.** Keep the `ETag` and ask with `If-None-Match`; the server answers `304` when
  nothing changed ([RFC 9111](https://www.rfc-editor.org/rfc/rfc9111)).
- **Events.** A push message or a real-time event says what changed; the client refreshes just
  that.
- **Versioned URLs.** Immutable media (`/images/ab12cd.jpg`) never changes, so it can be cached
  forever.

**Stale-while-revalidate** gives the best perceived speed: show the cached data at once,
fetch in the background, and update the screen if the answer differs.

## Eviction

Memory caches evict the **least recently used** items first and limit both the number of
items and their total cost. The package's
[`LRUCache`](../../Sources/MobileSystemDesign/Caching/LRUCache.swift) does both, with an
optional time to live, in O(1) per operation.

Respond to memory pressure: on iOS observe
[`UIApplication.didReceiveMemoryWarningNotification`](https://developer.apple.com/documentation/uikit/uiapplication/didreceivememorywarningnotification),
on Android implement
[`ComponentCallbacks2.onTrimMemory`](https://developer.android.com/reference/android/content/ComponentCallbacks2),
and trim the memory cache to a fraction of its limit. Keep disk caches in the Caches
directory (iOS) or `cacheDir` (Android) so the system can reclaim the space.

## Image loading pipeline

```text
request(url, targetSize)
  → memory cache (decoded bitmaps, keyed by url + size)
  → disk cache (encoded files)
  → network (with request deduplication and priority)
  → decode and downsample on a background thread
  → store in both caches → display
```

The points that matter in a design discussion:

1. **Downsample to the display size.** Decoded, a bitmap takes `width × height × 4` bytes:
   48 MB for a 12-megapixel photo, under 6 MB for a full-width thumbnail on a 3× screen.
   Ask the server for a size close to the display size, and decode at that size
   ([`CGImageSourceCreateThumbnailAtIndex`](<https://developer.apple.com/documentation/imageio/cgimagesourcecreatethumbnailatindex(_:_:_:)>),
   [`BitmapFactory.Options.inSampleSize`](https://developer.android.com/topic/performance/graphics/load-bitmap)).
2. **Decode off the main thread.** Decoding a large JPEG takes long enough to drop frames.
3. **Deduplicate requests.** Ten cells showing the same avatar make one download.
4. **Cancel and prioritize.** Cancel requests for cells that scrolled away; load visible cells
   before prefetched ones.
5. **Cost by decoded size.** The memory cache's cost is the decoded size, not the file size.

[`ClientBudget`](../../Sources/MobileSystemDesign/Estimation/CapacityEstimate.swift) computes
decoded sizes and how many images fit a memory budget, with overflow checks.

## What to say in an interview

- Which layer is the source of truth, and what the user sees offline.
- How stale data can be, per kind of data, and how it is refreshed.
- How the image pipeline keeps memory bounded and scrolling smooth.
- How the cache is cleared on sign-out, so the next user does not see the previous one's
  data.
