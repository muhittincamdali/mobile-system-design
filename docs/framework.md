# A framework for mobile system design

Mobile system design questions — "design the Instagram feed", "design WhatsApp", "design the
Uber rider app" — are about the **client**: what runs on a phone with a small battery, a
flaky network, limited memory and an operating system that may suspend or kill the app at any
moment. This page gives a structure for a 45–60 minute interview or a design review, and the
questions that show depth at each step.

## The steps

| Step                 | Time      | Output                                                           |
| -------------------- | --------- | ---------------------------------------------------------------- |
| 1. Clarify the task  | 5 min     | Functional and non-functional requirements, what is out of scope |
| 2. Estimate          | 3 min     | Rough request rates, payload sizes, storage on the device        |
| 3. High-level design | 10 min    | Client components, server components you rely on, data flow      |
| 4. API and data      | 10 min    | Endpoints or messages, pagination, the local data model          |
| 5. Deep dives        | 15–20 min | Two or three hard parts: offline, real time, media, sync         |
| 6. Wrap up           | 5 min     | Trade-offs, risks, what you would measure                        |

Leave room for the deep dives: they are where the interviewer learns the most.

## 1. Clarify the task

Ask before you draw. Typical questions:

- **Who uses it, and where?** Global users on low-end Android phones and 3G need smaller
  payloads and more offline support than office workers on recent iPhones.
- **Which features are in scope?** For a feed: reading, posting, liking, comments? Pick the
  core loop and say what you leave out.
- **What must work offline?** Reading cached content, writing changes that sync later, or
  nothing?
- **How fresh must data be?** Seconds (chat, ride tracking), minutes (feed), hours (catalog)?
- **Which platforms?** iOS, Android, both from one code base?

Write the non-functional requirements down: launch time, scroll smoothness, battery use, data
use, offline behaviour, privacy, accessibility, localization.

## 2. Estimate

A few numbers decide the design. How many requests per second will the backend see at peak?
How large is a page of the feed? How much will the app store on the device in a week? The
[`CapacityEstimate`](../Sources/MobileSystemDesign/Estimation/CapacityEstimate.swift) type and
the Estimator lab of the [example app](../Examples) do this arithmetic; the
[DocC article](../Sources/MobileSystemDesign/MobileSystemDesign.docc/EstimatingCapacity.md)
walks through an example.

On the client, estimate memory, not only bandwidth: a 12-megapixel photo is about 48 MB when
decoded for display, so an image pipeline must downsample before it caches.

## 3. High-level design

Draw the client as layers with one direction of dependency:

```text
┌──────────────────────────────────────────────┐
│ UI: screens and view models                  │
├──────────────────────────────────────────────┤
│ Domain: use cases, business rules            │
├──────────────────────────────────────────────┤
│ Data: repositories                           │
│   ├─ remote: API client, real-time channel   │
│   ├─ local: database, file store, caches     │
│   └─ sync: outbox, conflict resolution       │
├──────────────────────────────────────────────┤
│ Platform: networking, push, background work  │
└──────────────────────────────────────────────┘
```

Then name the server pieces the client talks to — API gateway, CDN for media, push service
(APNs, Firebase Cloud Messaging), real-time gateway — without designing them in depth unless
asked.

Say where the **source of truth** is for each kind of data. In an offline-first design the
screen reads only from the local store; the network fills the store. That one decision
simplifies loading states, offline behaviour and testing.

## 4. API and data

- **Protocol.** REST over HTTP/2 or HTTP/3 for request–response, a WebSocket or server-sent
  events for server push while the app is in the foreground, push notifications while it is
  not. GraphQL when many screens need different shapes of the same data.
- **Pagination.** Cursors, not offsets, for any list that changes while it is read. See
  [API design and pagination](topics/api-and-pagination.md).
- **Idempotency.** Every write that can be retried carries an idempotency key.
- **Local model.** Tables or entities, their keys, which fields are indexed, how long data is
  kept, and what is encrypted.

## 5. Deep dives

Pick the two or three areas the product depends on, and go deep:

| Product      | Deep dives                                                                                                                 |
| ------------ | -------------------------------------------------------------------------------------------------------------------------- |
| Feed         | [Pagination](topics/api-and-pagination.md), [image loading and caching](topics/caching-and-images.md), prefetching         |
| Chat         | [Real-time delivery and ordering](topics/resilience-and-real-time.md), [offline sending](topics/offline-and-sync.md), push |
| Ride hailing | Location updates and battery, [real-time tracking](case-studies/ride-tracking.md), maps                                    |
| Media        | Downloads in the background, storage limits, [offline playback](case-studies/offline-music.md)                             |

For each, describe the failure cases: no network, a slow network, the app killed mid-operation,
two devices editing the same thing, the server returning errors.

## 6. Wrap up

Summarize the trade-offs you made and what you would measure in production: launch time,
time to first content, scroll hitches, crash-free sessions, failed requests by type, outbox
size, battery and data use. Mention what you would do with more time.

## Signals reviewers look for

- You ask about requirements before designing.
- You reason about the device: memory, battery, network, background limits, app lifecycle.
- You handle failure as a normal case, not an afterthought.
- You make trade-offs explicit and justify them with numbers.
- You keep the server design proportionate: the question is about the app.

## Next

- [Topics](README.md#topics): the building blocks in depth.
- [Case studies](README.md#case-studies): the framework applied to four products.
