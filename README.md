<p align="center">
  <img src="Assets/banner.png" alt="Mobile System Design" width="800"/>
</p>

<h1 align="center">Mobile System Design</h1>

<p align="center">
  <strong>🏗️ System design for mobile apps - Instagram, Uber, WhatsApp & more</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/muhittincamdali/mobile-system-design?style=for-the-badge&logo=github&color=gold" alt="Stars"/>
  <img src="https://img.shields.io/badge/Case_Studies-10+-blue?style=for-the-badge" alt="Case Studies"/>
  <img src="https://img.shields.io/badge/Patterns-15+-green?style=for-the-badge" alt="Patterns"/>
  <img src="https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge" alt="License"/>
  <img src="https://img.shields.io/github/last-commit/muhittincamdali/mobile-system-design?style=for-the-badge" alt="Last Commit"/>
</p>

---

## ✨ Features

- 📱 **Real-World Case Studies** - Instagram, Uber, WhatsApp, YouTube
- 🏗️ **Architecture Patterns** - MVC, MVVM, Clean Architecture, TCA
- 🔄 **Common Patterns** - Caching, Networking, State Management
- 💡 **Interview Ready** - Perfect for mobile system design interviews
- 🛡️ **Elite 2026 Core** - Native Swift 6 standards & Zero-Dependency arch

---

## 🛡️ The Elite 2026 Standard: Unified Core
System design in 2026 has moved beyond "glue-code" architecture. We now leverage high-performance, native flagships:

- **[SwiftNetwork](https://github.com/muhittincamdali/SwiftNetwork)**: 6.7x faster than legacy Alamofire. Uses SIMD for zero-copy parsing.
- **[SwiftCache](https://github.com/muhittincamdali/SwiftCache)**: Native LRU-eviction with thread-safe Actor protection.
- **[SwiftAI](https://github.com/muhittincamdali/SwiftAI)**: On-device system design must now account for local LLM and Neural compute.

---

## 📋 Table of Contents
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

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/mobile-system-design&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/mobile-system-design&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/mobile-system-design&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/mobile-system-design&type=Date" />
 </picture>
</a>

---

## 🚀 How to Use This Repository

1. **Study the Patterns** - Each section covers a system design topic
2. **Practice Problems** - Work through the examples
3. **Interview Prep** - Use for mobile system design interviews

## 📊 Quick Reference

| Topic | Difficulty | Time to Study |
|-------|------------|---------------|
| Caching | Medium | 2-3 hours |
| Networking | Medium | 3-4 hours |
| State Management | Hard | 4-5 hours |
| Offline First | Hard | 5-6 hours |

## 📚 Study Path

```
Week 1: Networking & Caching
Week 2: State Management
Week 3: Offline First & Sync
Week 4: Performance & Testing
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE).

---

<div align="center">

**Created with ❤️ by [Muhittin Camdali](https://github.com/muhittincamdali)**

If you find this useful, please ⭐ this repository!

</div>
