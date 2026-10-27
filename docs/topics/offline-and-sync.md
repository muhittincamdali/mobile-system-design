# Offline support and sync

How an app keeps working without a network, keeps the user's changes safe, and reconciles
them with the server and with the user's other devices.

## Levels of offline support

| Level          | The user can                          | Needs                                |
| -------------- | ------------------------------------- | ------------------------------------ |
| None           | See an error                          | Nothing                              |
| Read           | See what was loaded before            | A local store as the source of truth |
| Read and write | Make changes that sync later          | An outbox, idempotent writes         |
| Collaborative  | Edit the same data on several devices | Conflict resolution                  |

Agree on the level in the requirements step: each one costs more than the one before.

## The local store is the source of truth

The screen observes the local database; the network writes into it. Loading, offline and
error states then become properties of the data ("last updated 5 minutes ago") rather than
separate screens. On iOS use [SwiftData](https://developer.apple.com/documentation/swiftdata)
or Core Data or SQLite; on Android use
[Room](https://developer.android.com/training/data-storage/room). Keep files the user created
in Application Support (iOS) or internal storage (Android), not in caches.

## The outbox

Every change the user makes goes into a persistent queue before anything is sent:

1. Write the change to the local store, so the screen shows it at once (optimistic update).
2. Append it to the outbox, with a UUID as idempotency key.
3. When the network is available, send the entries oldest first.
4. On success, remove the entry; on a permanent failure, roll the optimistic update back and
   tell the user.

Design points:

- **Order.** Send one entry at a time, oldest first, and keep a failed entry at the head;
  otherwise "rename folder" may arrive after "move file into folder".
- **Coalescing.** Liking and unliking a post ten times offline should send one request: a new
  change replaces the waiting one with the same key — but never the one being sent.
- **Retry policy.** Back off between attempts, honour `Retry-After`, and stop after a number
  of attempts; move the entry to a "failed" list the user can see.
- **Bounds.** Limit the queue length and the size of the file it is stored in.
- **When to send.** When the scene becomes active, when the network comes back
  ([`NWPathMonitor`](https://developer.apple.com/documentation/network/nwpathmonitor),
  [`ConnectivityManager.NetworkCallback`](https://developer.android.com/reference/android/net/ConnectivityManager.NetworkCallback)),
  and in background work
  ([BGTaskScheduler](https://developer.apple.com/documentation/backgroundtasks),
  [WorkManager](https://developer.android.com/develop/background-work/background-tasks/persistent)).

The package's [`Outbox`](../../Sources/MobileSystemDesign/Offline/Outbox.swift) implements
these points; the Offline likes lab in the [example app](../../Examples) shows them.

## Pulling changes

To bring the local store up to date, ask the server for what changed since the last sync:

```http
GET /sync?since=eyJ2IjoxODQyfQ
```

The server answers with changed and deleted records and a new token. Deletions must be
explicit ("tombstones"); otherwise a client cannot tell a deleted record from one it has not
seen. A push notification or a real-time event can tell the client to pull now instead of on
a timer.

## Conflicts

A conflict happens when two devices change the same record before seeing each other's
change. Strategies, from simple to involved:

| Strategy          | Result                                   | Fits                                 |
| ----------------- | ---------------------------------------- | ------------------------------------ |
| Server wins       | The client's change is dropped           | Data the server owns, such as prices |
| Last writer wins  | The later change is kept                 | Titles, settings, profile fields     |
| Field-level merge | Changes to different fields both survive | Records edited in parts              |
| Ask the user      | Both versions are shown                  | Documents where loss is unacceptable |
| CRDTs             | Concurrent edits merge automatically     | Collaborative text and lists         |

"Later" must not depend on whose phone clock is right: a phone set a day ahead would win every
conflict for a day. A **hybrid logical clock** combines the wall clock with a counter: it never
goes backwards, orders an edit after every edit the device has seen, and can reject
timestamps too far in the future ([Kulkarni et al.,
2014](https://cse.buffalo.edu/tech-reports/2014-04.pdf)). The package's
[`HybridLogicalClock`](../../Sources/MobileSystemDesign/Sync/HybridLogicalClock.swift) and
[`LWWRegister`](../../Sources/MobileSystemDesign/Sync/LWWRegister.swift) implement this.

## What to say in an interview

- The offline level the product needs, and why.
- Where the source of truth is, and how the UI shows freshness.
- How a change made offline reaches the server exactly once and in order.
- How conflicts are detected and resolved, and what the user sees.
- What happens when the user signs out with unsent changes.
