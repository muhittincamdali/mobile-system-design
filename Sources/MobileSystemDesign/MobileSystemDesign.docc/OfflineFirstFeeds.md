# Designing an offline-first feed

Page a feed, keep it readable without a network, save the user's changes until they can be
sent, and resolve edits from several devices.

## Overview

An offline-first app treats the network as an optimization: the screen shows local data at
once, changes are stored before they are sent, and synchronization happens in the background.
Four types cover the client side of that design:

| Concern                                                  | Type                                   |
| -------------------------------------------------------- | -------------------------------------- |
| Loading the feed page by page                            | ``Paginator``                            |
| Showing the last good data when the server cannot answer | ``LRUCache``                             |
| Keeping changes made offline until they are delivered    | ``Outbox``                               |
| Deciding which of two edits wins                         | ``HybridLogicalClock`` and ``LWWRegister`` |

### Page with cursors, not offsets

With `?offset=40`, a post published at the top of the feed shifts every later post by one,
and the next page repeats an item. A cursor names the last item seen, so the next page starts
after it whatever was inserted meanwhile. ``Paginator`` works with any `Hashable` cursor and
also guards against servers that get cursors wrong:

- items whose `id` is already in the list are skipped;
- a cursor that was already returned ends the list with
  ``Paginator/EndReason/repeatedCursor``;
- ``Paginator/emptyPageLimit`` pages in a row without new items end it with
  ``Paginator/EndReason/noProgress``;
- the list stops at ``Paginator/maxItems``, so a long session cannot exhaust memory.

Concurrent calls to ``Paginator/loadNextPage()`` share one request, so a fast scroll that
asks for more from several rows does not load the same page twice. ``Paginator/refresh()``
discards a page that was still loading for the old list.

### Fall back to the last good page

Keep the pages you loaded in an ``LRUCache`` and serve them when the network fails. The
`SystemDesignLab` example does this in its `FeedRepository` actor:

```swift
actor FeedRepository {
    private var pages = LRUCache<Int, Page<Post, Int>>(countLimit: 20, timeToLive: 600)

    func page(after cursor: Int?) async throws -> Page<Post, Int> {
        do {
            let page = try await retrier.run { _ in try await api.page(after: cursor) }
            pages.insert(page, forKey: cursor ?? 0, cost: page.items.count)
            return page
        } catch {
            guard let cached = pages.value(forKey: cursor ?? 0) else { throw error }
            return cached
        }
    }
}
```

For images, use the decoded size as the cost and trim the cache when the system reports
memory pressure; ``ClientBudget/decodedImageBytes(width:height:bytesPerPixel:)`` computes it.

### Save changes before sending them

A like, a comment or an edit must survive the app being killed in a tunnel. ``Outbox`` saves
each change to its ``OutboxStore`` before ``Outbox/enqueue(_:coalescingKey:now:)`` returns,
and sends the waiting changes when you call ``Outbox/flush(now:send:)``:

```swift
let store = FileOutboxStore<LikeChange>(fileURL: applicationSupport.appendingPathComponent("outbox.json"))
let outbox = try Outbox(store: store)

try await outbox.enqueue(LikeChange(postID: 42, liked: true), coalescingKey: "like-42")

let report = await outbox.flush { entry in
    try await api.setLike(entry.payload, idempotencyKey: entry.id)
}
```

Call `flush` when the scene becomes active and when `NWPathMonitor` reports a usable path.
The outbox keeps these promises:

- **Order.** Entries go oldest first. A temporary failure keeps the entry at the head and
  schedules it with the retry policy, so a later change never overtakes an earlier one.
- **Exactly-once effect.** Each entry has a UUID; send it as the idempotency key so the
  server can ignore a repeated request that had in fact arrived.
- **Coalescing.** With a `coalescingKey`, a newer change replaces the waiting one — liking and
  unliking a post ten times offline sends one request. The entry on the wire is never
  replaced.
- **Bounded.** ``Outbox/capacity`` limits the queue, a flush sends at most the entries that
  were waiting when it started, and ``Outbox/deadLetters`` keeps the newest rejected entries
  for the app to show, retry or discard.

Keep the file in Application Support, not in Caches: the system may delete caches, and the
entries are the user's unsent work. ``FileOutboxStore`` refuses to read a file larger than
its limit and reports a corrupted file as an error instead of starting empty.

### Resolve edits from several devices

When the same note title is edited on a phone and a tablet, each device keeps an
``LWWRegister`` and merges the copies it receives; all copies end with the same value, in any
order of merging. "Last" must not mean "the device whose clock is furthest ahead", so the
timestamps come from a ``HybridLogicalClock``:

```swift
var clock = HybridLogicalClock(node: deviceID)
var title = LWWRegister("Groceries", timestamp: try clock.tick())

// When a copy arrives from another device:
try title.merge(remote, using: &clock)
```

The hybrid clock follows the wall clock but never goes backwards.
``LWWRegister/merge(_:using:physicalTime:)`` passes the remote timestamp through
``HybridLogicalClock/receive(_:physicalTime:)`` before the copy can win, which orders the next
local edit after everything the device has seen. An edit made after seeing another edit therefore wins, even on a device
whose clock is behind. Timestamps more than ``HybridLogicalClock/maximumDrift`` ahead of the
local clock are rejected, so one device with a wrong clock cannot win every conflict.

Last-writer-wins drops the losing edit. That suits a title, a setting or a profile field; for
text that several people type into at the same time, use a sequence CRDT or merge on the
server.
