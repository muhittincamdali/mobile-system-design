<p align="center">
  <img src="Assets/banner.png" alt="Mobile System Design" width="800"/>
</p>

<h1 align="center">Mobile System Design</h1>

<p align="center">
  <strong>🏗️ System design for mobile apps - Instagram, Uber, WhatsApp & more</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/muhittincamdali/mobile-system-design?style=flat-square" alt="Stars"/>
  <img src="https://img.shields.io/badge/case_studies-10+-blue?style=flat-square" alt="Case Studies"/>
</p>

---

## Contents

- [Fundamentals](#fundamentals)
- [Case Studies](#case-studies)
  - [Instagram Feed](#instagram-feed)
  - [Uber](#uber)
  - [WhatsApp](#whatsapp)
  - [YouTube](#youtube)
  - [E-Commerce App](#e-commerce)
- [Common Patterns](#common-patterns)
- [Interview Tips](#interview-tips)

---

## Fundamentals

### Mobile System Design Framework

```
1. REQUIREMENTS (5 min)
   ├── Functional requirements
   ├── Non-functional requirements
   └── Constraints

2. HIGH-LEVEL DESIGN (10 min)
   ├── Architecture diagram
   ├── Main components
   └── Data flow

3. DEEP DIVE (20 min)
   ├── API design
   ├── Data models
   ├── Caching strategy
   ├── Offline support
   └── Performance

4. TRADE-OFFS (5 min)
   ├── Decisions made
   └── Alternatives considered
```

---

## Case Studies

### Instagram Feed

**Requirements:**
- Display photo/video feed
- Infinite scroll
- Like, comment, share
- Real-time updates
- Offline viewing

**Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT                                │
├─────────────┬─────────────┬─────────────┬──────────────────┤
│    View     │  ViewModel  │  Repository │    DataSource    │
└─────────────┴─────────────┴─────────────┴──────────────────┘
                                │                    │
                        ┌───────┴───────┐     ┌─────┴─────┐
                        │   Local DB    │     │  Remote   │
                        │  (Core Data)  │     │   API     │
                        └───────────────┘     └───────────┘
```

**Key Decisions:**

| Aspect | Decision | Reason |
|--------|----------|--------|
| Pagination | Cursor-based | Handles inserts/deletes |
| Caching | LRU + Disk | Memory + persistence |
| Images | Progressive JPEG | Fast preview |
| Updates | WebSocket | Real-time likes |

**API Design:**

```swift
// GET /api/v1/feed?cursor=xxx&limit=20
struct FeedResponse: Codable {
    let posts: [Post]
    let nextCursor: String?
    let hasMore: Bool
}

struct Post: Codable {
    let id: String
    let userId: String
    let mediaUrls: [URL]
    let caption: String
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Date
    let isLiked: Bool
}
```

**Caching Strategy:**

```swift
class FeedRepository {
    private let cache = NSCache<NSString, Post>()
    private let diskCache = DiskCache()
    private let api: FeedAPI
    
    func getFeed(cursor: String?) async throws -> FeedResponse {
        // 1. Return cached immediately
        if let cached = diskCache.getFeed() {
            return cached
        }
        
        // 2. Fetch from network
        let response = try await api.getFeed(cursor: cursor)
        
        // 3. Cache for offline
        diskCache.saveFeed(response)
        
        return response
    }
}
```

---

### Uber

**Requirements:**
- Request rides
- Real-time driver tracking
- ETA calculation
- Payment processing
- Ride history

**Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                       Uber App                               │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│  Map UI  │ Booking  │ Tracking │ Payment  │    Profile     │
└──────────┴──────────┴──────────┴──────────┴────────────────┘
           │                    │
     ┌─────┴─────┐       ┌─────┴─────┐
     │  MapKit   │       │ WebSocket │
     │ Location  │       │  Server   │
     └───────────┘       └───────────┘
```

**Real-time Tracking:**

```swift
class RideTracker {
    private var socket: WebSocket?
    
    func startTracking(rideId: String) {
        socket = WebSocket(url: "wss://tracking.uber.com/\(rideId)")
        
        socket?.onMessage = { [weak self] message in
            let update = try? JSONDecoder().decode(LocationUpdate.self, from: message)
            self?.updateDriverLocation(update)
        }
        
        socket?.connect()
    }
    
    private func updateDriverLocation(_ update: LocationUpdate?) {
        guard let update = update else { return }
        
        // Smooth animation between points
        animateMarker(from: currentLocation, to: update.location, duration: 1.0)
        
        // Update ETA
        calculateETA(from: update.location)
    }
}
```

**Location Efficiency:**

```swift
class LocationManager {
    func startUpdating(accuracy: LocationAccuracy) {
        switch accuracy {
        case .high: // Driver tracking
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 10 // meters
            
        case .low: // Background
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 100
        }
    }
}
```

---

### WhatsApp

**Requirements:**
- Real-time messaging
- End-to-end encryption
- Media sharing
- Read receipts
- Offline support

**Message Sync:**

```swift
class MessageSync {
    private let socket: WebSocket
    private let database: MessageDatabase
    
    // Optimistic UI update
    func sendMessage(_ message: Message) async {
        // 1. Save locally with pending status
        message.status = .pending
        await database.save(message)
        
        // 2. Update UI immediately
        NotificationCenter.default.post(name: .messageAdded, object: message)
        
        // 3. Send to server
        do {
            try await socket.send(message)
            message.status = .sent
        } catch {
            message.status = .failed
        }
        
        await database.update(message)
    }
}
```

**Encryption:**

```swift
class E2EEncryption {
    // Signal Protocol implementation
    func encrypt(_ message: String, for recipient: User) throws -> Data {
        let sessionCipher = SessionCipher(for: recipient.publicKey)
        return try sessionCipher.encrypt(message.data(using: .utf8)!)
    }
}
```

---

### YouTube

**Requirements:**
- Video streaming
- Adaptive bitrate
- Background playback
- Offline downloads
- Recommendations

**Video Player:**

```swift
class VideoPlayer {
    private let player: AVPlayer
    private let bufferManager: BufferManager
    
    func play(video: Video) {
        // HLS for adaptive streaming
        let asset = AVURLAsset(url: video.hlsURL)
        let item = AVPlayerItem(asset: asset)
        
        // Prefer WiFi quality
        item.preferredPeakBitRate = NetworkMonitor.isWiFi ? 5_000_000 : 1_500_000
        
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func handleBuffering() {
        // Preload next segments
        bufferManager.prefetch(next: 30) // seconds
    }
}
```

---

## Common Patterns

### Offline-First

```swift
class OfflineFirstRepository<T: Codable> {
    func getData() async throws -> T {
        // 1. Return cached data immediately
        if let cached = localCache.get() {
            return cached
        }
        
        // 2. Fetch fresh data
        let fresh = try await api.fetch()
        
        // 3. Update cache
        localCache.save(fresh)
        
        return fresh
    }
}
```

### Optimistic Updates

```swift
func likePost(_ post: Post) {
    // 1. Update UI immediately
    post.isLiked = true
    post.likesCount += 1
    
    // 2. Send to server
    Task {
        do {
            try await api.like(post.id)
        } catch {
            // 3. Rollback on failure
            post.isLiked = false
            post.likesCount -= 1
        }
    }
}
```

### Pagination

```swift
class PaginatedDataSource<T: Codable> {
    private var cursor: String?
    private var isLoading = false
    private var hasMore = true
    
    func loadMore() async throws -> [T] {
        guard !isLoading, hasMore else { return [] }
        
        isLoading = true
        defer { isLoading = false }
        
        let response = try await api.fetch(cursor: cursor, limit: 20)
        cursor = response.nextCursor
        hasMore = response.hasMore
        
        return response.items
    }
}
```

---

## Interview Tips

1. **Clarify requirements** before designing
2. **Start with high-level** architecture
3. **Draw diagrams** to communicate
4. **Discuss trade-offs** explicitly
5. **Consider edge cases** (offline, errors)
6. **Think about scale** (1M vs 1B users)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License
