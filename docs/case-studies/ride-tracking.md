# Case study: live ride tracking

"Design the rider app of an Uber-style service, focusing on the trip": request a ride, watch
the driver approach on a map, follow the trip.

## 1. Requirements

**Functional**

- Request a ride from the current location to a destination; see the price estimate.
- See the assigned driver's position move on the map, with an arrival estimate.
- Follow the trip; get notified on arrival.

**Non-functional**

- Driver position on the rider's screen a few seconds behind reality at most.
- Smooth marker movement, not jumps.
- Modest battery use on both apps; the driver app runs for hours.
- A ride request is never sent twice, even on a flaky network.

**Out of scope:** matching and pricing on the server, payments, the driver app's navigation.

## 2. Estimates

A driver app that sends a location every 4 seconds sends 900 updates an hour; at about 100
bytes each, that is about 90 kB an hour of payload — small. The cost is battery: GPS and the
radio waking up. The design therefore spends its effort on **when** to sample and send, not on
bandwidth.

## 3. High-level design

```text
Rider app
  TripScreen ── TripViewModel ── TripRepository ─┬─ RideAPI (request, cancel)   [idempotent]
                                                 ├─ TripChannel (WebSocket: driver positions, state)
                                                 └─ TripStore (current trip, last positions)
  MapView ── MarkerAnimator (interpolates between positions)

Driver app
  LocationProvider ── LocationBatcher ── TripChannel / LocationAPI
```

## 4. API and data

```http
POST /v1/rides                  Idempotency-Key: <uuid>
     { "pickup": {lat, lng}, "dropoff": {lat, lng}, "quote_id": "q_55" }
→    { "ride_id": "r_9", "state": "matching" }
```

```text
WebSocket /v1/rides/r_9/live
← { "type": "state", "state": "driver_assigned", "driver": {…}, "eta_s": 240 }
← { "type": "position", "seq": 311, "lat": …, "lng": …, "heading": 87, "speed": 9.4, "t": "…" }
```

The rider app keeps the trip state and the last few positions locally, so reopening the app
shows the trip at once.

## 5. Deep dives

### Requesting a ride exactly once

The rider taps **Request** on a weak connection; the request times out. Retrying without
protection could book two cars. The client generates an idempotency key when the user taps,
stores it with the pending request, and reuses it on every retry; the server returns the same
ride for the same key. The tap button is disabled until the request resolves.

### Sampling location on the driver app

- Use the platform's fused or significant-change providers rather than raw GPS where accuracy
  allows ([Core Location](https://developer.apple.com/documentation/corelocation),
  [Android location](https://developer.android.com/develop/sensors-and-location/location)).
- Sample more often when moving fast or near the pickup, less often when stationary.
- Batch points and send them together when the connection is poor; drop points older than
  the newest one already sent.
- Background location needs the right permission and, on iOS, the location background mode;
  explain why to the user.

### Smooth movement on the rider app

Positions arrive every few seconds and sometimes out of order. Ignore positions with a
sequence number lower than the last applied one, then animate the marker from its current
position to the new one over the update interval, rotating to the heading. If no update
arrives for a while, extrapolate briefly along the last speed and heading, then stop and show
a "connection lost" state rather than inventing movement.

### Connection and lifecycle

The live channel runs while the trip screen is visible. When the app goes to the background,
the socket is closed; state changes the rider must not miss (driver arrived, trip ended) are
sent as push notifications, and the app pulls the trip state when it returns. iOS Live
Activities can show the arrival estimate on the lock screen
([ActivityKit](https://developer.apple.com/documentation/activitykit)).

### Failure handling

Reconnect with backoff and jitter; after reconnecting, fetch the trip state before applying
new positions. A circuit breaker on the pricing endpoint keeps the request screen responsive
when pricing is down. See [Network resilience and real-time updates](../topics/resilience-and-real-time.md).

## 6. Trade-offs and metrics

- More frequent updates look smoother and cost battery on the driver's phone; adaptive
  sampling balances both.
- Interpolation hides jitter but can draw a car through a building on a sharp turn; snapping
  to the route polyline helps.
- Measure: position age on the rider's screen, reconnects per trip, duplicate ride requests
  prevented by idempotency keys, driver app battery use per hour.
