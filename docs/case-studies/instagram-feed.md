# Instagram Feed System Design

## Table of Contents

1. [Overview](#overview)
2. [Requirements Analysis](#requirements-analysis)
3. [High-Level Architecture](#high-level-architecture)
4. [Data Models](#data-models)
5. [Feed Generation](#feed-generation)
6. [Client Architecture](#client-architecture)
7. [Caching Strategy](#caching-strategy)
8. [Image Loading Pipeline](#image-loading-pipeline)
9. [Infinite Scroll Implementation](#infinite-scroll-implementation)
10. [Real-time Updates](#real-time-updates)
11. [Offline Support](#offline-support)
12. [Performance Optimization](#performance-optimization)
13. [Testing Strategy](#testing-strategy)
14. [Interview Discussion Points](#interview-discussion-points)

---

## Overview

The Instagram feed is one of the most complex mobile system design challenges. It combines multiple technical domains: efficient data fetching, sophisticated caching, smooth scrolling performance, real-time updates, and personalized content ranking.

### Scale Context

```
Daily Active Users: 500M+
Posts per day: 100M+
Feed requests per second: 10M+
Average feed load time target: < 500ms
Image variants per post: 6-8 resolutions
```

### Key Technical Challenges

| Challenge | Impact | Solution Domain |
|-----------|--------|-----------------|
| Feed latency | User engagement | Caching, prefetching |
| Scroll performance | User experience | Memory management, recycling |
| Data freshness | Content relevance | Real-time sync, pull-to-refresh |
| Bandwidth usage | User costs, speed | Image optimization, lazy loading |
| Battery consumption | Device health | Background task optimization |

---

## Requirements Analysis

### Functional Requirements

#### Core Features

1. **Feed Display**
   - Show posts from followed accounts
   - Display posts in ranked order (not chronological)
   - Support multiple media types (single image, carousel, video, Reels)
   - Show engagement metrics (likes, comments count)
   - Display user interactions (liked by friends)

2. **User Interactions**
   - Like/unlike posts with instant feedback
   - Double-tap to like with animation
   - Save posts to collections
   - Share posts via DM or external apps
   - Report/hide posts
   - Mute accounts

3. **Navigation**
   - Tap user avatar to view profile
   - Tap location to view location feed
   - Tap hashtags to view hashtag feed
   - Swipe between carousel images
   - Tap to pause/play video

4. **Feed Management**
   - Pull-to-refresh for new content
   - Infinite scroll for older content
   - "New Posts" indicator
   - Return to top functionality

#### Secondary Features

```swift
enum FeedFeature: CaseIterable {
    case stories          // Story tray at top
    case suggestedPosts   // "Suggested for you"
    case sponsoredContent // Advertisements
    case reelsPreview     // Short video previews
    case shoppingTags     // Product tags on posts
    case collaborations   // Multi-author posts
    case pinnedPosts      // Creator's pinned content
    case subscriptions    // Subscriber-only content
}
```

### Non-Functional Requirements

#### Performance Targets

```yaml
Feed Load Time:
  Cold start: < 2 seconds
  Warm start: < 500ms
  Cached: < 100ms

Scroll Performance:
  Frame rate: 60 FPS minimum
  Frame drops: < 1% of frames
  Memory per cell: < 2MB average

Image Loading:
  Thumbnail: < 200ms
  Full resolution: < 1 second
  Progressive loading: Required

Network Efficiency:
  Initial payload: < 50KB (metadata)
  Images: Lazy loaded on demand
  Prefetch window: 5-10 posts ahead
```

#### Reliability Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Availability | 99.9% | Feed loads successfully |
| Error rate | < 0.1% | Failed requests |
| Crash rate | < 0.01% | Feed-related crashes |
| Offline capability | 100% | Cached content available |

### Constraints

```swift
struct SystemConstraints {
    // Device constraints
    let minRAM: Int = 2  // GB
    let minStorage: Int = 100  // MB for cache
    let minOSVersion: String = "iOS 14.0"
    
    // Network constraints
    let assumedBandwidth: Range<Int> = 1...100  // Mbps
    let offlineSupportRequired: Bool = true
    let lowBandwidthModeRequired: Bool = true
    
    // Business constraints
    let adFrequency: Int = 5  // 1 ad per 5 posts
    let maxPostAge: TimeInterval = 48 * 3600  // 48 hours
    let maxFeedDepth: Int = 500  // Maximum posts to load
}
```

---

## High-Level Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           INSTAGRAM FEED SYSTEM                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        CLIENT LAYER                               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │   │
│  │  │   Feed UI   │  │   Feed VM   │  │   Feed Repository       │  │   │
│  │  │  Collection │◄─│   State     │◄─│   Data Orchestration    │  │   │
│  │  │   View      │  │   Machine   │  │                         │  │   │
│  │  └─────────────┘  └─────────────┘  └───────────┬─────────────┘  │   │
│  │                                                  │                 │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────▼─────────────┐  │   │
│  │  │   Image     │  │   Video     │  │   Network    │  Cache   │  │   │
│  │  │   Pipeline  │  │   Player    │  │   Service    │  Layer   │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                      │                                   │
│                                      ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         API GATEWAY                               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │   │
│  │  │   Auth      │  │   Rate      │  │   Request               │  │   │
│  │  │   Token     │  │   Limiting  │  │   Routing               │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                      │                                   │
│                                      ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      BACKEND SERVICES                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │   │
│  │  │   Feed      │  │   Ranking   │  │   Media                 │  │   │
│  │  │   Service   │◄─│   Service   │  │   Service               │  │   │
│  │  └──────┬──────┘  └─────────────┘  └─────────────────────────┘  │   │
│  │         │                                                         │   │
│  │  ┌──────▼──────┐  ┌─────────────┐  ┌─────────────────────────┐  │   │
│  │  │   Social    │  │   Content   │  │   Notification          │  │   │
│  │  │   Graph     │  │   Store     │  │   Service               │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

#### Client Components

```swift
// MARK: - Feed UI Layer

/// Main feed view controller responsible for:
/// - Managing collection view lifecycle
/// - Handling user interactions
/// - Coordinating with view model
class FeedViewController: UIViewController {
    // Collection view with compositional layout
    // Prefetching data source
    // Refresh control
    // Navigation handling
}

/// Feed cell types
enum FeedCellType {
    case singleImage(Post)
    case carousel(Post)
    case video(Post)
    case reel(Post)
    case sponsoredPost(Ad)
    case suggestedUsers([User])
    case storyTray([Story])
}

// MARK: - Feed ViewModel

/// Manages feed state and business logic
class FeedViewModel: ObservableObject {
    @Published var feedState: FeedState
    @Published var posts: [FeedItem]
    @Published var isLoading: Bool
    @Published var error: FeedError?
    
    // Pagination state
    private var cursor: String?
    private var hasMore: Bool = true
    
    // User interaction handling
    // Feed refresh logic
    // Error recovery
}

// MARK: - Feed Repository

/// Data orchestration layer
class FeedRepository {
    // Coordinates between:
    // - Network service (remote data)
    // - Cache service (local data)
    // - Database (persistent storage)
    
    // Implements:
    // - Cache-first strategy
    // - Background refresh
    // - Optimistic updates
}
```

### Data Flow

```
User Opens App
       │
       ▼
┌──────────────────┐
│ Check Cache Age  │
└────────┬─────────┘
         │
    ┌────┴────┐
    │ Fresh?  │
    └────┬────┘
         │
    ┌────┴────────────────┐
    │                     │
   Yes                   No
    │                     │
    ▼                     ▼
┌────────────┐    ┌────────────────┐
│ Load from  │    │ Show cached +  │
│ Cache      │    │ Fetch new      │
└────────────┘    └────────────────┘
    │                     │
    └─────────┬───────────┘
              │
              ▼
    ┌─────────────────┐
    │ Render Feed     │
    │ Start Prefetch  │
    └─────────────────┘
```

---

## Data Models

### Core Models

```swift
// MARK: - Post Model

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let author: UserSummary
    let content: PostContent
    let engagement: EngagementMetrics
    let metadata: PostMetadata
    let interactions: UserInteractions
    
    // Computed properties for UI
    var displayTimestamp: String {
        metadata.createdAt.timeAgoDisplay()
    }
    
    var shouldShowLikedBy: Bool {
        engagement.likedByFollowing.count > 0
    }
}

struct UserSummary: Codable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let avatarURL: URL
    let isVerified: Bool
    let isFollowing: Bool
    let hasActiveStory: Bool
}

// MARK: - Post Content

enum PostContent: Codable, Hashable {
    case singleMedia(MediaItem)
    case carousel([MediaItem])
    case reel(ReelContent)
    
    var mediaCount: Int {
        switch self {
        case .singleMedia: return 1
        case .carousel(let items): return items.count
        case .reel: return 1
        }
    }
    
    var primaryMedia: MediaItem {
        switch self {
        case .singleMedia(let item): return item
        case .carousel(let items): return items[0]
        case .reel(let content): return content.video
        }
    }
}

struct MediaItem: Codable, Hashable {
    let id: String
    let type: MediaType
    let aspectRatio: CGFloat
    let urls: MediaURLs
    let blurhash: String?
    let altText: String?
    let taggedUsers: [TaggedUser]
    let productTags: [ProductTag]
}

enum MediaType: String, Codable {
    case image
    case video
}

struct MediaURLs: Codable, Hashable {
    let thumbnail: URL      // 150x150
    let small: URL          // 320px wide
    let medium: URL         // 640px wide
    let large: URL          // 1080px wide
    let original: URL       // Full resolution
    
    func bestURL(for width: CGFloat, scale: CGFloat) -> URL {
        let targetWidth = width * scale
        switch targetWidth {
        case ..<200: return thumbnail
        case ..<400: return small
        case ..<800: return medium
        case ..<1200: return large
        default: return original
        }
    }
}

// MARK: - Engagement

struct EngagementMetrics: Codable, Hashable {
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
    let savesCount: Int
    let viewsCount: Int?  // For videos/reels
    let likedByFollowing: [UserSummary]
    
    var displayLikesCount: String {
        likesCount.abbreviatedString()
    }
    
    var displayCommentsCount: String {
        commentsCount.abbreviatedString()
    }
}

struct UserInteractions: Codable, Hashable {
    var isLiked: Bool
    var isSaved: Bool
    var likedAt: Date?
    var savedAt: Date?
}

// MARK: - Metadata

struct PostMetadata: Codable, Hashable {
    let createdAt: Date
    let editedAt: Date?
    let location: Location?
    let caption: Caption?
    let isSponsored: Bool
    let isPinned: Bool
    let commentsDisabled: Bool
    let likesHidden: Bool
}

struct Caption: Codable, Hashable {
    let text: String
    let mentions: [Mention]
    let hashtags: [Hashtag]
    let truncatedLength: Int
    
    var isExpandable: Bool {
        text.count > truncatedLength
    }
    
    var truncatedText: String {
        if text.count <= truncatedLength {
            return text
        }
        return String(text.prefix(truncatedLength)) + "..."
    }
}

struct Location: Codable, Hashable {
    let id: String
    let name: String
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Feed Response

struct FeedResponse: Codable {
    let posts: [FeedItem]
    let cursor: String?
    let hasMore: Bool
    let refreshInterval: TimeInterval
    let serverTime: Date
}

enum FeedItem: Codable, Hashable {
    case post(Post)
    case ad(Advertisement)
    case suggestedUsers(SuggestedUsersCard)
    case endOfFeed(EndOfFeedCard)
    
    var id: String {
        switch self {
        case .post(let post): return "post_\(post.id)"
        case .ad(let ad): return "ad_\(ad.id)"
        case .suggestedUsers(let card): return "suggested_\(card.id)"
        case .endOfFeed(let card): return "eof_\(card.id)"
        }
    }
}

struct Advertisement: Codable, Hashable {
    let id: String
    let advertiser: UserSummary
    let content: PostContent
    let callToAction: CallToAction
    let targetURL: URL
    let impressionURL: URL
    let clickURL: URL
}

struct CallToAction: Codable, Hashable {
    let text: String  // "Shop Now", "Learn More", etc.
    let style: CTAStyle
    
    enum CTAStyle: String, Codable {
        case primary
        case secondary
        case link
    }
}
```

### Database Schema

```swift
// MARK: - Core Data / SQLite Schema

/*
 TABLE posts (
     id TEXT PRIMARY KEY,
     author_id TEXT NOT NULL,
     content_type TEXT NOT NULL,
     content_json TEXT NOT NULL,
     engagement_json TEXT NOT NULL,
     metadata_json TEXT NOT NULL,
     interactions_json TEXT NOT NULL,
     created_at INTEGER NOT NULL,
     fetched_at INTEGER NOT NULL,
     feed_position INTEGER,
     is_seen INTEGER DEFAULT 0,
     FOREIGN KEY (author_id) REFERENCES users(id)
 );
 
 TABLE users (
     id TEXT PRIMARY KEY,
     username TEXT NOT NULL,
     display_name TEXT,
     avatar_url TEXT,
     is_verified INTEGER DEFAULT 0,
     is_following INTEGER DEFAULT 0,
     has_active_story INTEGER DEFAULT 0,
     updated_at INTEGER NOT NULL
 );
 
 TABLE media_cache (
     url TEXT PRIMARY KEY,
     local_path TEXT NOT NULL,
     size_bytes INTEGER NOT NULL,
     width INTEGER,
     height INTEGER,
     created_at INTEGER NOT NULL,
     last_accessed INTEGER NOT NULL,
     access_count INTEGER DEFAULT 1
 );
 
 TABLE feed_state (
     user_id TEXT PRIMARY KEY,
     cursor TEXT,
     last_refresh INTEGER,
     last_seen_post_id TEXT,
     scroll_position REAL
 );
 
 INDEX idx_posts_created ON posts(created_at DESC);
 INDEX idx_posts_feed_position ON posts(feed_position);
 INDEX idx_media_last_accessed ON media_cache(last_accessed);
 INDEX idx_media_size ON media_cache(size_bytes DESC);
*/

// MARK: - Core Data Entities

@objc(PostEntity)
class PostEntity: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var authorId: String
    @NSManaged var contentType: String
    @NSManaged var contentJSON: Data
    @NSManaged var engagementJSON: Data
    @NSManaged var metadataJSON: Data
    @NSManaged var interactionsJSON: Data
    @NSManaged var createdAt: Date
    @NSManaged var fetchedAt: Date
    @NSManaged var feedPosition: Int32
    @NSManaged var isSeen: Bool
    @NSManaged var author: UserEntity?
    
    func toPost() throws -> Post {
        let decoder = JSONDecoder()
        return Post(
            id: id,
            author: try author?.toUserSummary() ?? UserSummary.placeholder,
            content: try decoder.decode(PostContent.self, from: contentJSON),
            engagement: try decoder.decode(EngagementMetrics.self, from: engagementJSON),
            metadata: try decoder.decode(PostMetadata.self, from: metadataJSON),
            interactions: try decoder.decode(UserInteractions.self, from: interactionsJSON)
        )
    }
}
```

---

## Feed Generation

### Server-Side Feed Generation

```swift
// MARK: - Feed Generation (Conceptual Server Logic)

/// Feed generation follows a multi-stage pipeline:
/// 1. Candidate Generation - Get potential posts
/// 2. Ranking - Score and order posts
/// 3. Filtering - Remove unwanted content
/// 4. Diversification - Ensure variety
/// 5. Insertion - Add ads and suggestions

class FeedGenerationPipeline {
    
    // Stage 1: Candidate Generation
    func generateCandidates(for userId: String) -> [PostCandidate] {
        var candidates: [PostCandidate] = []
        
        // Primary sources
        candidates += getFollowingPosts(userId: userId)
        candidates += getCloseConnectionsPosts(userId: userId)
        
        // Secondary sources (for "Suggested" posts)
        candidates += getTopicsOfInterestPosts(userId: userId)
        candidates += getSimilarAccountsPosts(userId: userId)
        
        return candidates
    }
    
    // Stage 2: Ranking
    func rankPosts(_ candidates: [PostCandidate], for userId: String) -> [RankedPost] {
        return candidates.map { candidate in
            let score = calculateScore(candidate, for: userId)
            return RankedPost(post: candidate.post, score: score)
        }.sorted { $0.score > $1.score }
    }
    
    func calculateScore(_ candidate: PostCandidate, for userId: String) -> Double {
        var score = 0.0
        
        // Engagement prediction
        score += predictLikeProbability(candidate, userId) * 0.3
        score += predictCommentProbability(candidate, userId) * 0.2
        score += predictSaveProbability(candidate, userId) * 0.15
        score += predictShareProbability(candidate, userId) * 0.1
        
        // Relationship strength
        score += getRelationshipScore(userId, candidate.authorId) * 0.15
        
        // Recency
        score += getRecencyScore(candidate.createdAt) * 0.1
        
        return score
    }
    
    // Stage 3: Filtering
    func filterPosts(_ posts: [RankedPost], for userId: String) -> [RankedPost] {
        return posts.filter { post in
            // Remove already seen posts
            guard !hasUserSeen(post, userId) else { return false }
            
            // Remove blocked/muted accounts
            guard !isBlockedOrMuted(post.authorId, by: userId) else { return false }
            
            // Remove reported content
            guard !isReported(post) else { return false }
            
            // Content policy filtering
            guard passesContentPolicy(post) else { return false }
            
            return true
        }
    }
    
    // Stage 4: Diversification
    func diversify(_ posts: [RankedPost]) -> [RankedPost] {
        var result: [RankedPost] = []
        var authorCounts: [String: Int] = [:]
        var contentTypeCounts: [String: Int] = [:]
        
        for post in posts {
            let authorCount = authorCounts[post.authorId, default: 0]
            let typeCount = contentTypeCounts[post.contentType, default: 0]
            
            // Limit consecutive posts from same author
            guard authorCount < 2 else { continue }
            
            // Ensure content type variety
            if typeCount > 3 && result.count > 10 {
                // Demote but don't exclude
                continue
            }
            
            result.append(post)
            authorCounts[post.authorId, default: 0] += 1
            contentTypeCounts[post.contentType, default: 0] += 1
        }
        
        return result
    }
    
    // Stage 5: Insertion
    func insertCards(_ posts: [RankedPost], for userId: String) -> [FeedItem] {
        var items: [FeedItem] = []
        
        for (index, post) in posts.enumerated() {
            items.append(.post(post.toPost()))
            
            // Insert ad every 5 posts
            if (index + 1) % 5 == 0 {
                if let ad = getNextAd(for: userId) {
                    items.append(.ad(ad))
                }
            }
            
            // Insert suggested users at position 3
            if index == 2 {
                if let suggestions = getSuggestedUsers(for: userId) {
                    items.append(.suggestedUsers(suggestions))
                }
            }
        }
        
        return items
    }
}
```

### Client-Side Feed Management

```swift
// MARK: - Feed Manager

@MainActor
class FeedManager: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var items: [FeedItem] = []
    @Published private(set) var state: FeedState = .idle
    @Published private(set) var hasNewPosts: Bool = false
    
    // MARK: - Private State
    
    private var cursor: String?
    private var hasMore: Bool = true
    private var lastRefreshTime: Date?
    private var pendingNewPosts: [FeedItem] = []
    
    // MARK: - Dependencies
    
    private let repository: FeedRepository
    private let analytics: FeedAnalytics
    private let prefetcher: FeedPrefetcher
    
    // MARK: - Configuration
    
    private let refreshThreshold: TimeInterval = 300 // 5 minutes
    private let pageSize: Int = 20
    private let prefetchThreshold: Int = 5
    
    // MARK: - Public Methods
    
    func loadInitialFeed() async {
        guard state != .loading else { return }
        
        state = .loading
        
        do {
            // Try cache first
            if let cached = try await repository.getCachedFeed() {
                items = cached.items
                cursor = cached.cursor
                state = .loaded
                
                // Check if refresh needed
                if shouldRefresh(cached.fetchedAt) {
                    await refreshInBackground()
                }
            } else {
                // No cache, fetch from network
                let response = try await repository.fetchFeed(cursor: nil, limit: pageSize)
                items = response.posts
                cursor = response.cursor
                hasMore = response.hasMore
                lastRefreshTime = Date()
                state = .loaded
                
                // Cache the response
                await repository.cacheFeed(response)
            }
            
            // Start prefetching
            prefetcher.startPrefetching(for: items)
            
        } catch {
            state = .error(error)
            analytics.trackError(error, context: "initial_load")
        }
    }
    
    func refresh() async {
        guard state != .refreshing else { return }
        
        let previousState = state
        state = .refreshing
        
        do {
            let response = try await repository.fetchFeed(cursor: nil, limit: pageSize)
            
            // Merge with existing items (dedupe)
            let newItems = mergeItems(new: response.posts, existing: items)
            
            withAnimation {
                items = newItems
            }
            
            cursor = response.cursor
            hasMore = response.hasMore
            lastRefreshTime = Date()
            hasNewPosts = false
            state = .loaded
            
            // Update cache
            await repository.cacheFeed(response)
            
            analytics.trackRefresh(newPostCount: response.posts.count)
            
        } catch {
            state = previousState
            analytics.trackError(error, context: "refresh")
            throw error
        }
    }
    
    func loadMore() async {
        guard state == .loaded, hasMore, let cursor = cursor else { return }
        
        state = .loadingMore
        
        do {
            let response = try await repository.fetchFeed(cursor: cursor, limit: pageSize)
            
            items.append(contentsOf: response.posts)
            self.cursor = response.cursor
            hasMore = response.hasMore
            state = .loaded
            
            // Prefetch new items
            prefetcher.startPrefetching(for: response.posts)
            
            analytics.trackPagination(page: items.count / pageSize)
            
        } catch {
            state = .loaded // Allow retry
            analytics.trackError(error, context: "load_more")
        }
    }
    
    func checkForNewPosts() async {
        guard let lastRefresh = lastRefreshTime,
              Date().timeIntervalSince(lastRefresh) > 60 else {
            return
        }
        
        do {
            let response = try await repository.checkNewPosts(since: lastRefresh)
            
            if response.hasNewPosts {
                pendingNewPosts = response.posts
                hasNewPosts = true
            }
        } catch {
            // Silent failure - not critical
        }
    }
    
    func showNewPosts() {
        guard !pendingNewPosts.isEmpty else { return }
        
        withAnimation {
            items.insert(contentsOf: pendingNewPosts, at: 0)
            hasNewPosts = false
            pendingNewPosts = []
        }
    }
    
    // MARK: - User Interactions
    
    func likePost(_ postId: String) async {
        // Optimistic update
        updatePostInteraction(postId) { interactions in
            interactions.isLiked = true
            interactions.likedAt = Date()
        }
        
        updatePostEngagement(postId) { engagement in
            engagement.likesCount += 1
        }
        
        // Network request
        do {
            try await repository.likePost(postId)
            analytics.trackLike(postId: postId)
        } catch {
            // Rollback
            updatePostInteraction(postId) { interactions in
                interactions.isLiked = false
                interactions.likedAt = nil
            }
            updatePostEngagement(postId) { engagement in
                engagement.likesCount -= 1
            }
        }
    }
    
    func unlikePost(_ postId: String) async {
        // Optimistic update
        updatePostInteraction(postId) { interactions in
            interactions.isLiked = false
            interactions.likedAt = nil
        }
        
        updatePostEngagement(postId) { engagement in
            engagement.likesCount -= 1
        }
        
        // Network request
        do {
            try await repository.unlikePost(postId)
            analytics.trackUnlike(postId: postId)
        } catch {
            // Rollback
            updatePostInteraction(postId) { interactions in
                interactions.isLiked = true
                interactions.likedAt = Date()
            }
            updatePostEngagement(postId) { engagement in
                engagement.likesCount += 1
            }
        }
    }
    
    func savePost(_ postId: String) async {
        updatePostInteraction(postId) { $0.isSaved = true }
        
        do {
            try await repository.savePost(postId)
        } catch {
            updatePostInteraction(postId) { $0.isSaved = false }
        }
    }
    
    func hidePost(_ postId: String) {
        withAnimation {
            items.removeAll { $0.id == "post_\(postId)" }
        }
        
        Task {
            try? await repository.hidePost(postId)
        }
    }
    
    // MARK: - Private Helpers
    
    private func shouldRefresh(_ cacheDate: Date) -> Bool {
        Date().timeIntervalSince(cacheDate) > refreshThreshold
    }
    
    private func refreshInBackground() async {
        do {
            let response = try await repository.fetchFeed(cursor: nil, limit: pageSize)
            
            // Check for new content
            let newPostIds = Set(response.posts.compactMap { 
                if case .post(let post) = $0 { return post.id }
                return nil
            })
            
            let existingPostIds = Set(items.compactMap {
                if case .post(let post) = $0 { return post.id }
                return nil
            })
            
            let hasNewContent = !newPostIds.subtracting(existingPostIds).isEmpty
            
            if hasNewContent {
                pendingNewPosts = response.posts.filter { item in
                    guard case .post(let post) = item else { return false }
                    return !existingPostIds.contains(post.id)
                }
                hasNewPosts = true
            }
            
            // Update cache
            await repository.cacheFeed(response)
            
        } catch {
            // Silent failure
        }
    }
    
    private func mergeItems(new: [FeedItem], existing: [FeedItem]) -> [FeedItem] {
        var existingIds = Set(existing.map { $0.id })
        var merged = new
        
        for item in existing {
            if !existingIds.contains(item.id) {
                merged.append(item)
            }
        }
        
        return merged
    }
    
    private func updatePostInteraction(_ postId: String, update: (inout UserInteractions) -> Void) {
        guard let index = items.firstIndex(where: { $0.id == "post_\(postId)" }),
              case .post(var post) = items[index] else { return }
        
        update(&post.interactions)
        items[index] = .post(post)
    }
    
    private func updatePostEngagement(_ postId: String, update: (inout EngagementMetrics) -> Void) {
        guard let index = items.firstIndex(where: { $0.id == "post_\(postId)" }),
              case .post(var post) = items[index] else { return }
        
        update(&post.engagement)
        items[index] = .post(post)
    }
}

// MARK: - Feed State

enum FeedState: Equatable {
    case idle
    case loading
    case loaded
    case refreshing
    case loadingMore
    case error(Error)
    
    static func == (lhs: FeedState, rhs: FeedState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.loaded, .loaded),
             (.refreshing, .refreshing),
             (.loadingMore, .loadingMore):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
```

---

## Client Architecture

### MVVM + Clean Architecture

```swift
// MARK: - Presentation Layer

/// Feed Screen - SwiftUI View
struct FeedScreen: View {
    @StateObject private var viewModel = FeedViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            FeedContentView(viewModel: viewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { feedToolbar }
                .refreshable { await viewModel.refresh() }
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
        .task {
            await viewModel.loadInitialFeed()
        }
    }
    
    @ToolbarContentBuilder
    private var feedToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Image("instagram_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 30)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button(action: viewModel.openNotifications) {
                    Image(systemName: "heart")
                }
                
                Button(action: viewModel.openMessages) {
                    Image(systemName: "paperplane")
                }
                .overlay(unreadBadge)
            }
        }
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            Task { await viewModel.checkForNewPosts() }
        case .background:
            viewModel.saveScrollPosition()
        default:
            break
        }
    }
}

/// Feed Content View
struct FeedContentView: View {
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            feedList
            
            if viewModel.hasNewPosts {
                newPostsIndicator
            }
        }
    }
    
    private var feedList: some View {
        ScrollViewReader { proxy in
            LazyVStack(spacing: 0) {
                // Story Tray
                StoryTray(stories: viewModel.stories)
                    .id("top")
                
                // Feed Items
                ForEach(viewModel.items, id: \.id) { item in
                    FeedItemView(item: item, viewModel: viewModel)
                        .onAppear {
                            viewModel.onItemAppear(item)
                        }
                }
                
                // Loading Indicator
                if viewModel.state == .loadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .onChange(of: viewModel.shouldScrollToTop) { shouldScroll in
                if shouldScroll {
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }
    
    private var newPostsIndicator: some View {
        Button(action: viewModel.showNewPosts) {
            HStack {
                Image(systemName: "arrow.up")
                Text("New Posts")
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.blue))
        }
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

/// Individual Feed Item View
struct FeedItemView: View {
    let item: FeedItem
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        switch item {
        case .post(let post):
            PostView(post: post, viewModel: viewModel)
        case .ad(let ad):
            AdView(ad: ad)
        case .suggestedUsers(let card):
            SuggestedUsersView(card: card)
        case .endOfFeed(let card):
            EndOfFeedView(card: card)
        }
    }
}

// MARK: - Post View

struct PostView: View {
    let post: Post
    @ObservedObject var viewModel: FeedViewModel
    @State private var showComments = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            PostHeader(post: post)
            
            // Media Content
            PostMediaView(content: post.content)
                .onDoubleTap {
                    viewModel.likePost(post.id)
                }
            
            // Action Buttons
            PostActions(post: post, viewModel: viewModel)
            
            // Engagement Info
            PostEngagement(post: post)
            
            // Caption
            if let caption = post.metadata.caption {
                PostCaption(author: post.author, caption: caption)
            }
            
            // Comments Preview
            if post.engagement.commentsCount > 0 {
                CommentsPreview(post: post)
                    .onTapGesture { showComments = true }
            }
            
            // Timestamp
            Text(post.displayTimestamp)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $showComments) {
            CommentsSheet(postId: post.id)
        }
    }
}

struct PostHeader: View {
    let post: Post
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar with story ring
            AvatarView(
                url: post.author.avatarURL,
                hasStory: post.author.hasActiveStory,
                size: 32
            )
            
            // Username and location
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(post.author.username)
                        .font(.subheadline.bold())
                    
                    if post.author.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                
                if let location = post.metadata.location {
                    Text(location.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // More options
            Button(action: {}) {
                Image(systemName: "ellipsis")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct PostMediaView: View {
    let content: PostContent
    @State private var currentIndex = 0
    
    var body: some View {
        switch content {
        case .singleMedia(let media):
            SingleMediaView(media: media)
            
        case .carousel(let items):
            CarouselView(items: items, currentIndex: $currentIndex)
            
        case .reel(let reel):
            ReelPreviewView(reel: reel)
        }
    }
}

struct SingleMediaView: View {
    let media: MediaItem
    @State private var isLoaded = false
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: media.urls.bestURL(for: geometry.size.width, scale: UIScreen.main.scale)) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onAppear { isLoaded = true }
                case .failure:
                    errorView
                @unknown default:
                    placeholder
                }
            }
        }
        .aspectRatio(media.aspectRatio, contentMode: .fit)
    }
    
    private var placeholder: some View {
        ZStack {
            if let blurhash = media.blurhash {
                BlurHashView(blurHash: blurhash)
            } else {
                Color.gray.opacity(0.3)
            }
            
            ProgressView()
        }
    }
    
    private var errorView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "photo")
                .foregroundColor(.gray)
        }
    }
}

struct CarouselView: View {
    let items: [MediaItem]
    @Binding var currentIndex: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    SingleMediaView(media: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom page indicator
            if items.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.blue : Color.white.opacity(0.5))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .aspectRatio(items[0].aspectRatio, contentMode: .fit)
    }
}

struct PostActions: View {
    let post: Post
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Like
            Button(action: { viewModel.toggleLike(post.id) }) {
                Image(systemName: post.interactions.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(post.interactions.isLiked ? .red : .primary)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Comment
            Button(action: { viewModel.openComments(post.id) }) {
                Image(systemName: "bubble.right")
            }
            
            // Share
            Button(action: { viewModel.sharePost(post.id) }) {
                Image(systemName: "paperplane")
            }
            
            Spacer()
            
            // Save
            Button(action: { viewModel.toggleSave(post.id) }) {
                Image(systemName: post.interactions.isSaved ? "bookmark.fill" : "bookmark")
            }
        }
        .font(.title2)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct PostEngagement: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Liked by friends
            if let friend = post.engagement.likedByFollowing.first {
                HStack(spacing: 4) {
                    Text("Liked by")
                    Text(friend.username).bold()
                    if post.engagement.likedByFollowing.count > 1 {
                        Text("and")
                        Text("\(post.engagement.likesCount - 1) others").bold()
                    }
                }
                .font(.subheadline)
            } else if !post.metadata.likesHidden {
                Text("\(post.engagement.displayLikesCount) likes")
                    .font(.subheadline.bold())
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - ViewModel

@MainActor
class FeedViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var items: [FeedItem] = []
    @Published private(set) var stories: [Story] = []
    @Published private(set) var state: FeedState = .idle
    @Published private(set) var hasNewPosts: Bool = false
    @Published var shouldScrollToTop: Bool = false
    
    // MARK: - Private Properties
    
    private let feedManager: FeedManager
    private let storyManager: StoryManager
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    
    // Scroll position tracking
    private var lastVisibleItemIndex: Int = 0
    private var scrollOffset: CGFloat = 0
    
    // Prefetching
    private let prefetchThreshold = 5
    
    // MARK: - Initialization
    
    init(
        feedManager: FeedManager = .shared,
        storyManager: StoryManager = .shared,
        analyticsService: AnalyticsService = .shared
    ) {
        self.feedManager = feedManager
        self.storyManager = storyManager
        self.analyticsService = analyticsService
        
        setupBindings()
    }
    
    private func setupBindings() {
        feedManager.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
        
        feedManager.$state
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
        
        feedManager.$hasNewPosts
            .receive(on: DispatchQueue.main)
            .assign(to: &$hasNewPosts)
        
        storyManager.$stories
            .receive(on: DispatchQueue.main)
            .assign(to: &$stories)
    }
    
    // MARK: - Public Methods
    
    func loadInitialFeed() async {
        await feedManager.loadInitialFeed()
        await storyManager.loadStories()
    }
    
    func refresh() async {
        await feedManager.refresh()
        await storyManager.refreshStories()
    }
    
    func onItemAppear(_ item: FeedItem) {
        // Track position
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            lastVisibleItemIndex = index
            
            // Check if we need to load more
            if index >= items.count - prefetchThreshold {
                Task {
                    await feedManager.loadMore()
                }
            }
        }
        
        // Track impression
        if case .post(let post) = item {
            analyticsService.trackImpression(postId: post.id)
        }
    }
    
    func toggleLike(_ postId: String) {
        guard let post = findPost(postId) else { return }
        
        Task {
            if post.interactions.isLiked {
                await feedManager.unlikePost(postId)
            } else {
                await feedManager.likePost(postId)
            }
        }
    }
    
    func toggleSave(_ postId: String) {
        guard let post = findPost(postId) else { return }
        
        Task {
            if post.interactions.isSaved {
                await feedManager.unsavePost(postId)
            } else {
                await feedManager.savePost(postId)
            }
        }
    }
    
    func showNewPosts() {
        feedManager.showNewPosts()
        shouldScrollToTop = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.shouldScrollToTop = false
        }
    }
    
    func checkForNewPosts() async {
        await feedManager.checkForNewPosts()
    }
    
    func saveScrollPosition() {
        UserDefaults.standard.set(lastVisibleItemIndex, forKey: "feed_scroll_position")
    }
    
    // MARK: - Navigation
    
    func openComments(_ postId: String) {
        // Navigation logic
    }
    
    func sharePost(_ postId: String) {
        // Share sheet logic
    }
    
    func openNotifications() {
        // Navigate to notifications
    }
    
    func openMessages() {
        // Navigate to DMs
    }
    
    // MARK: - Private Helpers
    
    private func findPost(_ id: String) -> Post? {
        for item in items {
            if case .post(let post) = item, post.id == id {
                return post
            }
        }
        return nil
    }
}
```

---

## Caching Strategy

### Multi-Layer Cache Architecture

```swift
// MARK: - Cache Architecture

/*
 ┌─────────────────────────────────────────────────────────────┐
 │                    CACHE HIERARCHY                          │
 ├─────────────────────────────────────────────────────────────┤
 │                                                             │
 │  L1: In-Memory Cache (NSCache)                             │
 │  ├── Feed items (decoded)                                  │
 │  ├── Images (processed)                                    │
 │  └── TTL: Session duration                                 │
 │                                                             │
 │  L2: Disk Cache (FileManager)                              │
 │  ├── Feed JSON (compressed)                                │
 │  ├── Images (original + thumbnails)                        │
 │  └── TTL: 7 days (LRU eviction at 500MB)                  │
 │                                                             │
 │  L3: Database (Core Data / SQLite)                         │
 │  ├── Post metadata                                         │
 │  ├── User interactions                                     │
 │  └── TTL: 30 days                                         │
 │                                                             │
 └─────────────────────────────────────────────────────────────┘
*/

// MARK: - Cache Manager

actor CacheManager {
    
    // MARK: - Singleton
    
    static let shared = CacheManager()
    
    // MARK: - L1: Memory Cache
    
    private let memoryCache = NSCache<NSString, CacheEntry>()
    private var memoryKeys = Set<String>()
    
    // MARK: - L2: Disk Cache
    
    private let diskCacheURL: URL
    private let fileManager = FileManager.default
    private var diskCacheSize: Int64 = 0
    private let maxDiskCacheSize: Int64 = 500 * 1024 * 1024  // 500MB
    
    // MARK: - Configuration
    
    private let defaultMemoryTTL: TimeInterval = 3600  // 1 hour
    private let defaultDiskTTL: TimeInterval = 7 * 24 * 3600  // 7 days
    
    // MARK: - Initialization
    
    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = caches.appendingPathComponent("FeedCache", isDirectory: true)
        
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024  // 50MB
        
        Task {
            await calculateDiskCacheSize()
        }
    }
    
    // MARK: - Public Interface
    
    func get<T: Codable>(_ key: String, type: T.Type) async -> T? {
        // L1: Memory
        if let entry = memoryCache.object(forKey: key as NSString),
           !entry.isExpired,
           let data = entry.data as? T {
            return data
        }
        
        // L2: Disk
        if let data = await getDiskCache(key, type: type) {
            // Promote to L1
            let entry = CacheEntry(data: data, expiresAt: Date().addingTimeInterval(defaultMemoryTTL))
            memoryCache.setObject(entry, forKey: key as NSString)
            return data
        }
        
        return nil
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, memoryTTL: TimeInterval? = nil, diskTTL: TimeInterval? = nil) async {
        let memTTL = memoryTTL ?? defaultMemoryTTL
        let dskTTL = diskTTL ?? defaultDiskTTL
        
        // L1: Memory
        let entry = CacheEntry(data: value, expiresAt: Date().addingTimeInterval(memTTL))
        memoryCache.setObject(entry, forKey: key as NSString)
        memoryKeys.insert(key)
        
        // L2: Disk
        await setDiskCache(value, forKey: key, ttl: dskTTL)
    }
    
    func remove(_ key: String) async {
        memoryCache.removeObject(forKey: key as NSString)
        memoryKeys.remove(key)
        await removeDiskCache(key)
    }
    
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
        memoryKeys.removeAll()
    }
    
    func clearDiskCache() async {
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        diskCacheSize = 0
    }
    
    func clearExpired() async {
        // Memory cache handles its own expiration via NSCache
        
        // Disk cache cleanup
        await cleanupDiskCache()
    }
    
    // MARK: - Disk Cache Operations
    
    private func getDiskCache<T: Codable>(_ key: String, type: T.Type) async -> T? {
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256Hash)
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let wrapper = try JSONDecoder().decode(DiskCacheWrapper<T>.self, from: data)
            
            guard Date() < wrapper.expiresAt else {
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
            
            // Update last access time
            try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
            
            return wrapper.value
        } catch {
            return nil
        }
    }
    
    private func setDiskCache<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval) async {
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256Hash)
        
        let wrapper = DiskCacheWrapper(value: value, expiresAt: Date().addingTimeInterval(ttl))
        
        do {
            let data = try JSONEncoder().encode(wrapper)
            try data.write(to: fileURL)
            
            diskCacheSize += Int64(data.count)
            
            // Check if we need to evict
            if diskCacheSize > maxDiskCacheSize {
                await evictLRUEntries()
            }
        } catch {
            // Log error
        }
    }
    
    private func removeDiskCache(_ key: String) async {
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256Hash)
        
        if let attrs = try? fileManager.attributesOfItem(atPath: fileURL.path),
           let size = attrs[.size] as? Int64 {
            diskCacheSize -= size
        }
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    private func evictLRUEntries() async {
        let targetSize = maxDiskCacheSize * 80 / 100  // Evict to 80%
        
        guard let files = try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else { return }
        
        let sortedFiles = files.sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let date2 = (try? file2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return date1 < date2
        }
        
        for file in sortedFiles {
            guard diskCacheSize > targetSize else { break }
            
            if let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
                diskCacheSize -= Int64(size)
            }
            
            try? fileManager.removeItem(at: file)
        }
    }
    
    private func cleanupDiskCache() async {
        guard let files = try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: nil) else { return }
        
        for file in files {
            do {
                let data = try Data(contentsOf: file)
                let wrapper = try JSONDecoder().decode(DiskCacheWrapper<EmptyDecodable>.self, from: data)
                
                if Date() >= wrapper.expiresAt {
                    if let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
                        diskCacheSize -= Int64(size)
                    }
                    try? fileManager.removeItem(at: file)
                }
            } catch {
                // Invalid cache file, remove it
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    private func calculateDiskCacheSize() async {
        guard let files = try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: [.fileSizeKey]) else { return }
        
        diskCacheSize = files.reduce(0) { total, file in
            let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
}

// MARK: - Supporting Types

class CacheEntry: NSObject {
    let data: Any
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() >= expiresAt
    }
    
    init(data: Any, expiresAt: Date) {
        self.data = data
        self.expiresAt = expiresAt
    }
}

struct DiskCacheWrapper<T: Codable>: Codable {
    let value: T
    let expiresAt: Date
}

struct EmptyDecodable: Codable {}

// MARK: - Feed Cache

actor FeedCache {
    
    private let cacheManager = CacheManager.shared
    private let database: FeedDatabase
    
    private let feedKey = "main_feed"
    private let feedTTL: TimeInterval = 300  // 5 minutes
    
    init(database: FeedDatabase = .shared) {
        self.database = database
    }
    
    func getCachedFeed() async -> CachedFeed? {
        // Try memory/disk cache first
        if let cached = await cacheManager.get(feedKey, type: CachedFeed.self) {
            return cached
        }
        
        // Fall back to database
        if let posts = await database.fetchFeedPosts() {
            return CachedFeed(
                items: posts.map { .post($0) },
                cursor: await database.getFeedCursor(),
                fetchedAt: await database.getLastRefreshTime() ?? Date.distantPast
            )
        }
        
        return nil
    }
    
    func cacheFeed(_ response: FeedResponse) async {
        let cached = CachedFeed(
            items: response.posts,
            cursor: response.cursor,
            fetchedAt: Date()
        )
        
        // Cache in memory/disk
        await cacheManager.set(cached, forKey: feedKey, memoryTTL: feedTTL)
        
        // Persist to database
        await database.saveFeedPosts(response.posts)
        await database.saveFeedCursor(response.cursor)
        await database.saveLastRefreshTime(Date())
    }
    
    func invalidate() async {
        await cacheManager.remove(feedKey)
    }
    
    func updatePost(_ post: Post) async {
        // Update in memory cache
        if var cached = await cacheManager.get(feedKey, type: CachedFeed.self) {
            if let index = cached.items.firstIndex(where: { 
                if case .post(let p) = $0 { return p.id == post.id }
                return false
            }) {
                cached.items[index] = .post(post)
                await cacheManager.set(cached, forKey: feedKey, memoryTTL: feedTTL)
            }
        }
        
        // Update in database
        await database.updatePost(post)
    }
}

struct CachedFeed: Codable {
    var items: [FeedItem]
    let cursor: String?
    let fetchedAt: Date
}
```

---

## Image Loading Pipeline

### High-Performance Image Pipeline

```swift
// MARK: - Image Pipeline

actor ImagePipeline {
    
    // MARK: - Singleton
    
    static let shared = ImagePipeline()
    
    // MARK: - Caches
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let processedCache = NSCache<NSString, UIImage>()
    private let diskCache: DiskImageCache
    
    // MARK: - Loading State
    
    private var activeLoads: [URL: Task<UIImage?, Error>] = [:]
    private var loadingProgress: [URL: Progress] = [:]
    
    // MARK: - Configuration
    
    private let maxConcurrentLoads = 6
    private let loadSemaphore: AsyncSemaphore
    
    // MARK: - Initialization
    
    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 100 * 1024 * 1024  // 100MB
        
        processedCache.countLimit = 50
        processedCache.totalCostLimit = 50 * 1024 * 1024  // 50MB
        
        diskCache = DiskImageCache()
        loadSemaphore = AsyncSemaphore(value: maxConcurrentLoads)
        
        setupMemoryWarningObserver()
    }
    
    // MARK: - Public Interface
    
    func loadImage(
        from url: URL,
        size: CGSize? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        priority: TaskPriority = .medium
    ) async throws -> UIImage? {
        
        let cacheKey = cacheKey(for: url, size: size)
        
        // L1: Processed cache (if size specified)
        if let size = size,
           let processed = processedCache.object(forKey: cacheKey as NSString) {
            return processed
        }
        
        // L2: Memory cache
        if let cached = memoryCache.object(forKey: url as NSURL) {
            if let size = size {
                let processed = await processImage(cached, targetSize: size, contentMode: contentMode)
                processedCache.setObject(processed, forKey: cacheKey as NSString, cost: processed.memoryCost)
                return processed
            }
            return cached
        }
        
        // L3: Disk cache
        if let diskImage = await diskCache.getImage(for: url) {
            memoryCache.setObject(diskImage, forKey: url as NSURL, cost: diskImage.memoryCost)
            
            if let size = size {
                let processed = await processImage(diskImage, targetSize: size, contentMode: contentMode)
                processedCache.setObject(processed, forKey: cacheKey as NSString, cost: processed.memoryCost)
                return processed
            }
            return diskImage
        }
        
        // Network load
        return try await loadFromNetwork(url: url, size: size, contentMode: contentMode, priority: priority)
    }
    
    func prefetch(urls: [URL]) {
        for url in urls {
            Task(priority: .low) {
                _ = try? await loadImage(from: url, priority: .low)
            }
        }
    }
    
    func cancelLoad(for url: URL) {
        activeLoads[url]?.cancel()
        activeLoads[url] = nil
    }
    
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
        processedCache.removeAllObjects()
    }
    
    // MARK: - Private Methods
    
    private func loadFromNetwork(
        url: URL,
        size: CGSize?,
        contentMode: UIView.ContentMode,
        priority: TaskPriority
    ) async throws -> UIImage? {
        
        // Coalesce duplicate requests
        if let existingTask = activeLoads[url] {
            return try await existingTask.value
        }
        
        let task = Task(priority: priority) { () -> UIImage? in
            await loadSemaphore.wait()
            defer { Task { await loadSemaphore.signal() } }
            
            // Download
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ImageLoadError.invalidResponse
            }
            
            // Decode
            guard let image = await decodeImage(data: data) else {
                throw ImageLoadError.decodingFailed
            }
            
            // Cache original
            memoryCache.setObject(image, forKey: url as NSURL, cost: image.memoryCost)
            await diskCache.saveImage(image, for: url)
            
            return image
        }
        
        activeLoads[url] = task
        
        defer {
            activeLoads[url] = nil
        }
        
        let image = try await task.value
        
        // Process if needed
        if let size = size, let image = image {
            let processed = await processImage(image, targetSize: size, contentMode: contentMode)
            let cacheKey = self.cacheKey(for: url, size: size)
            processedCache.setObject(processed, forKey: cacheKey as NSString, cost: processed.memoryCost)
            return processed
        }
        
        return image
    }
    
    private func decodeImage(data: Data) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let options: [CFString: Any] = [
                    kCGImageSourceShouldCache: true,
                    kCGImageSourceShouldCacheImmediately: true
                ]
                
                guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
                      let cgImage = CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let image = UIImage(cgImage: cgImage)
                continuation.resume(returning: image)
            }
        }
    }
    
    private func processImage(
        _ image: UIImage,
        targetSize: CGSize,
        contentMode: UIView.ContentMode
    ) async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let processed = renderer.image { context in
                    let rect: CGRect
                    
                    switch contentMode {
                    case .scaleAspectFill:
                        rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: targetSize).aspectFillRect(for: image.size))
                    case .scaleAspectFit:
                        rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: targetSize))
                    default:
                        rect = CGRect(origin: .zero, size: targetSize)
                    }
                    
                    image.draw(in: rect)
                }
                
                continuation.resume(returning: processed)
            }
        }
    }
    
    private func cacheKey(for url: URL, size: CGSize?) -> String {
        if let size = size {
            return "\(url.absoluteString)_\(Int(size.width))x\(Int(size.height))"
        }
        return url.absoluteString
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearMemoryCache()
        }
    }
}

// MARK: - Disk Image Cache

actor DiskImageCache {
    
    private let cacheURL: URL
    private let fileManager = FileManager.default
    private let maxSize: Int64 = 200 * 1024 * 1024  // 200MB
    private var currentSize: Int64 = 0
    
    init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheURL = caches.appendingPathComponent("ImageCache", isDirectory: true)
        
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        
        Task {
            await calculateCurrentSize()
        }
    }
    
    func getImage(for url: URL) async -> UIImage? {
        let fileURL = fileURL(for: url)
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        // Update access time
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func saveImage(_ image: UIImage, for url: URL) async {
        let fileURL = fileURL(for: url)
        
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        
        try? data.write(to: fileURL)
        currentSize += Int64(data.count)
        
        if currentSize > maxSize {
            await evictOldestEntries()
        }
    }
    
    private func fileURL(for url: URL) -> URL {
        cacheURL.appendingPathComponent(url.absoluteString.sha256Hash)
    }
    
    private func calculateCurrentSize() async {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.fileSizeKey]) else { return }
        
        currentSize = files.reduce(0) { total, file in
            let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
    
    private func evictOldestEntries() async {
        let targetSize = maxSize * 70 / 100
        
        guard let files = try? fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else { return }
        
        let sortedFiles = files.sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let date2 = (try? file2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return date1 < date2
        }
        
        for file in sortedFiles {
            guard currentSize > targetSize else { break }
            
            if let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
                currentSize -= Int64(size)
            }
            
            try? fileManager.removeItem(at: file)
        }
    }
}

// MARK: - SwiftUI Integration

struct AsyncCachedImage: View {
    let url: URL
    let targetSize: CGSize?
    let contentMode: ContentMode
    let placeholder: AnyView
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(
        url: URL,
        targetSize: CGSize? = nil,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> some View = { Color.gray.opacity(0.3) }
    ) {
        self.url = url
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.placeholder = AnyView(placeholder())
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode == .fill ? .fill : .fit)
            } else {
                placeholder
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        
        let uiContentMode: UIView.ContentMode = contentMode == .fill ? .scaleAspectFill : .scaleAspectFit
        
        image = try? await ImagePipeline.shared.loadImage(
            from: url,
            size: targetSize,
            contentMode: uiContentMode
        )
        
        isLoading = false
    }
}

// MARK: - Prefetcher

class FeedPrefetcher {
    
    private let imagePipeline = ImagePipeline.shared
    private var prefetchTasks: [String: Task<Void, Never>] = [:]
    
    func startPrefetching(for items: [FeedItem]) {
        let mediaURLs = items.flatMap { item -> [URL] in
            guard case .post(let post) = item else { return [] }
            
            switch post.content {
            case .singleMedia(let media):
                return [media.urls.medium]
            case .carousel(let items):
                return items.map { $0.urls.medium }
            case .reel(let reel):
                return [reel.video.urls.thumbnail]
            }
        }
        
        Task {
            await imagePipeline.prefetch(urls: mediaURLs)
        }
    }
    
    func cancelPrefetching(for items: [FeedItem]) {
        for item in items {
            guard case .post(let post) = item else { continue }
            
            let urls = post.content.allMediaURLs
            for url in urls {
                Task {
                    await imagePipeline.cancelLoad(for: url)
                }
            }
        }
    }
}

// MARK: - Extensions

extension UIImage {
    var memoryCost: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

extension PostContent {
    var allMediaURLs: [URL] {
        switch self {
        case .singleMedia(let media):
            return [media.urls.medium]
        case .carousel(let items):
            return items.map { $0.urls.medium }
        case .reel(let reel):
            return [reel.video.urls.thumbnail]
        }
    }
}

enum ImageLoadError: Error {
    case invalidResponse
    case decodingFailed
    case cancelled
}
```

---

## Infinite Scroll Implementation

```swift
// MARK: - Infinite Scroll

/// Collection View with efficient infinite scroll
class FeedCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, FeedItem>!
    private let viewModel: FeedViewModel
    
    private let prefetchThreshold = 5
    private var isLoadingMore = false
    
    // MARK: - Section Definition
    
    enum Section: Hashable {
        case stories
        case feed
    }
    
    // MARK: - Initialization
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
        setupRefreshControl()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
        // Register cells
        collectionView.register(StoryTrayCell.self, forCellWithReuseIdentifier: StoryTrayCell.reuseIdentifier)
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: PostCell.reuseIdentifier)
        collectionView.register(AdCell.self, forCellWithReuseIdentifier: AdCell.reuseIdentifier)
        collectionView.register(SuggestedUsersCell.self, forCellWithReuseIdentifier: SuggestedUsersCell.reuseIdentifier)
        collectionView.register(LoadingFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingFooter.reuseIdentifier)
        
        view.addSubview(collectionView)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let section = self?.dataSource.snapshot().sectionIdentifiers[safe: sectionIndex] else {
                return nil
            }
            
            switch section {
            case .stories:
                return self?.createStoriesSection()
            case .feed:
                return self?.createFeedSection()
            }
        }
    }
    
    private func createStoriesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(80), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.interGroupSpacing = 8
        
        return section
    }
    
    private func createFeedSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // Footer for loading indicator
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        section.boundarySupplementaryItems = [footer]
        
        return section
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            self?.configureCell(for: item, at: indexPath)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoadingFooter.reuseIdentifier, for: indexPath) as? LoadingFooter
            footer?.isLoading = self?.isLoadingMore ?? false
            return footer
        }
    }
    
    private func configureCell(for item: FeedItem, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .post(let post):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
            cell.configure(with: post, delegate: self)
            return cell
            
        case .ad(let ad):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCell.reuseIdentifier, for: indexPath) as! AdCell
            cell.configure(with: ad)
            return cell
            
        case .suggestedUsers(let card):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedUsersCell.reuseIdentifier, for: indexPath) as! SuggestedUsersCell
            cell.configure(with: card)
            return cell
            
        case .endOfFeed(let card):
            // Handle end of feed
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
            return cell
        }
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        // Observe viewModel changes and update snapshot
        // Using Combine or observation framework
    }
    
    // MARK: - Actions
    
    @objc private func handleRefresh() {
        Task {
            await viewModel.refresh()
            
            await MainActor.run {
                collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Data Updates
    
    func applySnapshot(items: [FeedItem], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FeedItem>()
        
        snapshot.appendSections([.feed])
        snapshot.appendItems(items, toSection: .feed)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate

extension FeedCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount = dataSource.snapshot().numberOfItems
        
        // Check if we're near the end
        if indexPath.item >= itemCount - prefetchThreshold {
            loadMoreIfNeeded()
        }
        
        // Track impression
        if let item = dataSource.itemIdentifier(for: indexPath),
           case .post(let post) = item {
            viewModel.trackImpression(postId: post.id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Cancel any pending image loads
        if let cell = cell as? PostCell {
            cell.cancelImageLoading()
        }
    }
    
    private func loadMoreIfNeeded() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        updateLoadingFooter(isLoading: true)
        
        Task {
            await viewModel.loadMore()
            
            await MainActor.run {
                isLoadingMore = false
                updateLoadingFooter(isLoading: false)
            }
        }
    }
    
    private func updateLoadingFooter(isLoading: Bool) {
        let footerIndexPath = IndexPath(item: 0, section: 0)
        
        if let footer = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: footerIndexPath) as? LoadingFooter {
            footer.isLoading = isLoading
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension FeedCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let items = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        
        let urls = items.flatMap { item -> [URL] in
            guard case .post(let post) = item else { return [] }
            return post.content.allMediaURLs
        }
        
        Task {
            await ImagePipeline.shared.prefetch(urls: urls)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let items = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        
        for item in items {
            guard case .post(let post) = item else { continue }
            
            for url in post.content.allMediaURLs {
                Task {
                    await ImagePipeline.shared.cancelLoad(for: url)
                }
            }
        }
    }
}

// MARK: - PostCellDelegate

extension FeedCollectionViewController: PostCellDelegate {
    
    func postCellDidTapLike(_ cell: PostCell, postId: String) {
        Task {
            await viewModel.toggleLike(postId)
        }
    }
    
    func postCellDidDoubleTap(_ cell: PostCell, postId: String) {
        Task {
            await viewModel.likePost(postId)
        }
        
        // Show heart animation
        cell.showLikeAnimation()
    }
    
    func postCellDidTapComment(_ cell: PostCell, postId: String) {
        viewModel.openComments(postId)
    }
    
    func postCellDidTapShare(_ cell: PostCell, postId: String) {
        viewModel.sharePost(postId)
    }
    
    func postCellDidTapSave(_ cell: PostCell, postId: String) {
        Task {
            await viewModel.toggleSave(postId)
        }
    }
    
    func postCellDidTapAuthor(_ cell: PostCell, userId: String) {
        // Navigate to profile
    }
}

// MARK: - Supporting Views

class LoadingFooter: UICollectionReusableView {
    
    static let reuseIdentifier = "LoadingFooter"
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

---

## Real-time Updates

```swift
// MARK: - Real-time Updates

actor RealtimeUpdateManager {
    
    // MARK: - Dependencies
    
    private let webSocketService: WebSocketService
    private let feedManager: FeedManager
    private let notificationCenter: NotificationCenter
    
    // MARK: - State
    
    private var isConnected = false
    private var subscriptions: Set<String> = []
    private var reconnectTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        webSocketService: WebSocketService = .shared,
        feedManager: FeedManager = .shared,
        notificationCenter: NotificationCenter = .default
    ) {
        self.webSocketService = webSocketService
        self.feedManager = feedManager
        self.notificationCenter = notificationCenter
    }
    
    // MARK: - Connection Management
    
    func connect() async {
        guard !isConnected else { return }
        
        do {
            try await webSocketService.connect()
            isConnected = true
            
            // Subscribe to feed updates
            await subscribeToFeedUpdates()
            
            // Start listening
            await startListening()
            
        } catch {
            scheduleReconnect()
        }
    }
    
    func disconnect() async {
        isConnected = false
        reconnectTask?.cancel()
        await webSocketService.disconnect()
    }
    
    private func scheduleReconnect() {
        reconnectTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)  // 5 seconds
            guard !Task.isCancelled else { return }
            await connect()
        }
    }
    
    // MARK: - Subscriptions
    
    private func subscribeToFeedUpdates() async {
        await webSocketService.subscribe(to: .feedUpdates)
        subscriptions.insert("feed_updates")
    }
    
    // MARK: - Message Handling
    
    private func startListening() async {
        for await message in webSocketService.messages {
            await handleMessage(message)
        }
    }
    
    private func handleMessage(_ message: WebSocketMessage) async {
        switch message.type {
        case .newPost:
            await handleNewPost(message.payload)
            
        case .postUpdate:
            await handlePostUpdate(message.payload)
            
        case .postDeleted:
            await handlePostDeleted(message.payload)
            
        case .engagementUpdate:
            await handleEngagementUpdate(message.payload)
            
        case .connectionStatus:
            handleConnectionStatus(message.payload)
        }
    }
    
    private func handleNewPost(_ payload: [String: Any]) async {
        guard let postData = payload["post"] as? [String: Any],
              let post = try? decodePost(from: postData) else { return }
        
        // Notify feed manager of new post
        await MainActor.run {
            feedManager.addPendingPost(post)
        }
        
        // Post notification
        notificationCenter.post(name: .newPostAvailable, object: nil, userInfo: ["post": post])
    }
    
    private func handlePostUpdate(_ payload: [String: Any]) async {
        guard let postId = payload["post_id"] as? String,
              let updates = payload["updates"] as? [String: Any] else { return }
        
        await MainActor.run {
            feedManager.updatePost(postId, with: updates)
        }
    }
    
    private func handlePostDeleted(_ payload: [String: Any]) async {
        guard let postId = payload["post_id"] as? String else { return }
        
        await MainActor.run {
            feedManager.removePost(postId)
        }
    }
    
    private func handleEngagementUpdate(_ payload: [String: Any]) async {
        guard let postId = payload["post_id"] as? String,
              let likesCount = payload["likes_count"] as? Int,
              let commentsCount = payload["comments_count"] as? Int else { return }
        
        await MainActor.run {
            feedManager.updateEngagement(postId, likes: likesCount, comments: commentsCount)
        }
    }
    
    private func handleConnectionStatus(_ payload: [String: Any]) {
        if let status = payload["status"] as? String, status == "disconnected" {
            isConnected = false
            scheduleReconnect()
        }
    }
    
    private func decodePost(from data: [String: Any]) throws -> Post {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(Post.self, from: jsonData)
    }
}

// MARK: - WebSocket Service

actor WebSocketService {
    
    static let shared = WebSocketService()
    
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession
    private let url: URL
    
    private var messagesContinuation: AsyncStream<WebSocketMessage>.Continuation?
    
    var messages: AsyncStream<WebSocketMessage> {
        AsyncStream { continuation in
            self.messagesContinuation = continuation
        }
    }
    
    private init() {
        self.session = URLSession(configuration: .default)
        self.url = URL(string: "wss://api.instagram.com/realtime")!
    }
    
    func connect() async throws {
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        // Start receiving messages
        receiveMessage()
    }
    
    func disconnect() async {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        messagesContinuation?.finish()
    }
    
    func subscribe(to channel: RealtimeChannel) async {
        let message = WebSocketMessage(
            type: .subscribe,
            payload: ["channel": channel.rawValue]
        )
        
        try? await send(message)
    }
    
    func send(_ message: WebSocketMessage) async throws {
        guard let data = try? JSONEncoder().encode(message) else { return }
        try await webSocket?.send(.data(data))
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                        self?.messagesContinuation?.yield(wsMessage)
                    }
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                        self?.messagesContinuation?.yield(wsMessage)
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving
                self?.receiveMessage()
                
            case .failure:
                self?.messagesContinuation?.finish()
            }
        }
    }
}

// MARK: - Models

struct WebSocketMessage: Codable {
    let type: MessageType
    let payload: [String: Any]
    
    enum MessageType: String, Codable {
        case subscribe
        case newPost = "new_post"
        case postUpdate = "post_update"
        case postDeleted = "post_deleted"
        case engagementUpdate = "engagement_update"
        case connectionStatus = "connection_status"
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    init(type: MessageType, payload: [String: Any]) {
        self.type = type
        self.payload = payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(MessageType.self, forKey: .type)
        
        // Decode payload as generic dictionary
        let payloadContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        var dict = [String: Any]()
        // ... decode dynamic keys
        payload = dict
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        // ... encode payload
    }
}

enum RealtimeChannel: String {
    case feedUpdates = "feed_updates"
    case notifications = "notifications"
    case directMessages = "direct_messages"
}

// MARK: - Notifications

extension Notification.Name {
    static let newPostAvailable = Notification.Name("newPostAvailable")
}

struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
```

---

## Offline Support

```swift
// MARK: - Offline Support

/// Offline capability manager for feed
class OfflineFeedManager {
    
    // MARK: - Dependencies
    
    private let database: FeedDatabase
    private let networkMonitor: NetworkMonitor
    private let syncQueue: OperationQueue
    
    // MARK: - State
    
    @Published private(set) var isOffline: Bool = false
    private var pendingActions: [PendingAction] = []
    
    // MARK: - Initialization
    
    init(
        database: FeedDatabase = .shared,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.database = database
        self.networkMonitor = networkMonitor
        self.syncQueue = OperationQueue()
        self.syncQueue.maxConcurrentOperationCount = 1
        
        setupNetworkMonitoring()
        loadPendingActions()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected
                
                if isConnected {
                    self?.syncPendingActions()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Offline Actions
    
    func queueAction(_ action: PendingAction) {
        pendingActions.append(action)
        savePendingActions()
        
        if !isOffline {
            syncPendingActions()
        }
    }
    
    func likePostOffline(_ postId: String) {
        let action = PendingAction(
            id: UUID().uuidString,
            type: .like,
            postId: postId,
            timestamp: Date()
        )
        
        queueAction(action)
        
        // Update local state immediately
        Task {
            await database.updatePostInteraction(postId, isLiked: true)
        }
    }
    
    func unlikePostOffline(_ postId: String) {
        // Check if there's a pending like - if so, just remove it
        if let index = pendingActions.firstIndex(where: { $0.type == .like && $0.postId == postId }) {
            pendingActions.remove(at: index)
            savePendingActions()
            return
        }
        
        let action = PendingAction(
            id: UUID().uuidString,
            type: .unlike,
            postId: postId,
            timestamp: Date()
        )
        
        queueAction(action)
        
        Task {
            await database.updatePostInteraction(postId, isLiked: false)
        }
    }
    
    func savePostOffline(_ postId: String) {
        let action = PendingAction(
            id: UUID().uuidString,
            type: .save,
            postId: postId,
            timestamp: Date()
        )
        
        queueAction(action)
        
        Task {
            await database.updatePostInteraction(postId, isSaved: true)
        }
    }
    
    // MARK: - Sync
    
    private func syncPendingActions() {
        guard !pendingActions.isEmpty else { return }
        
        let actionsToSync = pendingActions
        pendingActions.removeAll()
        savePendingActions()
        
        for action in actionsToSync {
            let operation = SyncOperation(action: action) { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure:
                    // Re-queue failed action
                    self?.queueAction(action)
                }
            }
            
            syncQueue.addOperation(operation)
        }
    }
    
    // MARK: - Persistence
    
    private func savePendingActions() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(pendingActions) {
            UserDefaults.standard.set(data, forKey: "pending_feed_actions")
        }
    }
    
    private func loadPendingActions() {
        if let data = UserDefaults.standard.data(forKey: "pending_feed_actions"),
           let actions = try? JSONDecoder().decode([PendingAction].self, from: data) {
            pendingActions = actions
        }
    }
    
    // MARK: - Cancellables
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Pending Action

struct PendingAction: Codable, Identifiable {
    let id: String
    let type: ActionType
    let postId: String
    let timestamp: Date
    var retryCount: Int = 0
    
    enum ActionType: String, Codable {
        case like
        case unlike
        case save
        case unsave
        case hide
        case report
    }
}

// MARK: - Sync Operation

class SyncOperation: Operation {
    
    private let action: PendingAction
    private let completion: (Result<Void, Error>) -> Void
    
    init(action: PendingAction, completion: @escaping (Result<Void, Error>) -> Void) {
        self.action = action
        self.completion = completion
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                switch action.type {
                case .like:
                    try await APIService.shared.likePost(action.postId)
                case .unlike:
                    try await APIService.shared.unlikePost(action.postId)
                case .save:
                    try await APIService.shared.savePost(action.postId)
                case .unsave:
                    try await APIService.shared.unsavePost(action.postId)
                case .hide:
                    try await APIService.shared.hidePost(action.postId)
                case .report:
                    try await APIService.shared.reportPost(action.postId)
                }
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
}

// MARK: - Network Monitor

class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(path) ?? .unknown
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        }
        return .unknown
    }
}
```

---

## Performance Optimization

### Memory Management

```swift
// MARK: - Memory Management

class FeedMemoryManager {
    
    static let shared = FeedMemoryManager()
    
    private let memoryWarningThreshold: Float = 0.7
    private var currentMemoryUsage: Float = 0
    
    private init() {
        setupMemoryMonitoring()
    }
    
    private func setupMemoryMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // Periodic memory check
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkMemoryUsage()
        }
    }
    
    @objc private func handleMemoryWarning() {
        // Aggressive cleanup
        ImagePipeline.shared.clearMemoryCache()
        CacheManager.shared.clearMemoryCache()
        
        // Notify feed to reduce items
        NotificationCenter.default.post(name: .reduceMemoryUsage, object: nil)
    }
    
    private func checkMemoryUsage() {
        let memoryUsage = getMemoryUsage()
        currentMemoryUsage = memoryUsage
        
        if memoryUsage > memoryWarningThreshold {
            // Preemptive cleanup
            Task {
                await ImagePipeline.shared.clearMemoryCache()
            }
        }
    }
    
    private func getMemoryUsage() -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        
        let usedMemory = Float(info.resident_size)
        let totalMemory = Float(ProcessInfo.processInfo.physicalMemory)
        
        return usedMemory / totalMemory
    }
}

extension Notification.Name {
    static let reduceMemoryUsage = Notification.Name("reduceMemoryUsage")
}
```

### Cell Recycling Optimization

```swift
// MARK: - Optimized Post Cell

class PostCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PostCell"
    
    // MARK: - UI Components
    
    private let headerView = PostHeaderView()
    private let mediaContainerView = MediaContainerView()
    private let actionsView = PostActionsView()
    private let engagementLabel = UILabel()
    private let captionLabel = ExpandableLabel()
    private let timestampLabel = UILabel()
    
    // MARK: - State
    
    private var postId: String?
    private var imageLoadTask: Task<Void, Never>?
    
    weak var delegate: PostCellDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel pending operations
        imageLoadTask?.cancel()
        imageLoadTask = nil
        
        // Reset state
        postId = nil
        mediaContainerView.reset()
        actionsView.reset()
        captionLabel.text = nil
        
        // Important: Don't reset static content unnecessarily
    }
    
    // MARK: - Configuration
    
    func configure(with post: Post, delegate: PostCellDelegate?) {
        self.postId = post.id
        self.delegate = delegate
        
        // Header
        headerView.configure(
            username: post.author.username,
            avatarURL: post.author.avatarURL,
            isVerified: post.author.isVerified,
            location: post.metadata.location?.name,
            hasStory: post.author.hasActiveStory
        )
        
        // Media
        configureMedia(post.content)
        
        // Actions
        actionsView.configure(
            isLiked: post.interactions.isLiked,
            isSaved: post.interactions.isSaved
        )
        
        // Engagement
        configureEngagement(post.engagement)
        
        // Caption
        if let caption = post.metadata.caption {
            captionLabel.configure(
                username: post.author.username,
                text: caption.text,
                truncatedLength: caption.truncatedLength
            )
        }
        
        // Timestamp
        timestampLabel.text = post.displayTimestamp
    }
    
    private func configureMedia(_ content: PostContent) {
        imageLoadTask = Task {
            switch content {
            case .singleMedia(let media):
                await loadSingleMedia(media)
            case .carousel(let items):
                await loadCarousel(items)
            case .reel(let reel):
                await loadReelThumbnail(reel)
            }
        }
    }
    
    private func loadSingleMedia(_ media: MediaItem) async {
        let targetSize = mediaContainerView.bounds.size
        
        guard !Task.isCancelled else { return }
        
        // Show placeholder immediately
        if let blurhash = media.blurhash {
            await MainActor.run {
                mediaContainerView.showBlurhash(blurhash)
            }
        }
        
        // Load actual image
        let image = try? await ImagePipeline.shared.loadImage(
            from: media.urls.medium,
            size: targetSize
        )
        
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            if let image = image {
                mediaContainerView.showImage(image, animated: true)
            }
        }
    }
    
    private func loadCarousel(_ items: [MediaItem]) async {
        // Load first image immediately
        if let firstItem = items.first {
            await loadSingleMedia(firstItem)
        }
        
        // Prefetch remaining images
        let remainingURLs = items.dropFirst().map { $0.urls.medium }
        await ImagePipeline.shared.prefetch(urls: remainingURLs)
    }
    
    private func loadReelThumbnail(_ reel: ReelContent) async {
        await loadSingleMedia(reel.video)
    }
    
    private func configureEngagement(_ engagement: EngagementMetrics) {
        if let friend = engagement.likedByFollowing.first {
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: "Liked by "))
            text.append(NSAttributedString(string: friend.username, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
            
            if engagement.likedByFollowing.count > 1 {
                text.append(NSAttributedString(string: " and "))
                text.append(NSAttributedString(string: "\(engagement.likesCount - 1) others", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
            }
            
            engagementLabel.attributedText = text
        } else {
            engagementLabel.text = "\(engagement.displayLikesCount) likes"
            engagementLabel.font = .boldSystemFont(ofSize: 14)
        }
    }
    
    // MARK: - Actions
    
    func cancelImageLoading() {
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }
    
    func showLikeAnimation() {
        mediaContainerView.showHeartAnimation()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Layout code...
        contentView.addSubview(headerView)
        contentView.addSubview(mediaContainerView)
        contentView.addSubview(actionsView)
        contentView.addSubview(engagementLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(timestampLabel)
        
        // Constraints...
    }
}

// MARK: - Media Container View

class MediaContainerView: UIView {
    
    private let imageView = UIImageView()
    private let blurhashView = UIImageView()
    private let heartImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(blurhashView)
        addSubview(imageView)
        
        heartImageView.image = UIImage(systemName: "heart.fill")
        heartImageView.tintColor = .white
        heartImageView.alpha = 0
        addSubview(heartImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        imageView.image = nil
        blurhashView.image = nil
        blurhashView.alpha = 1
    }
    
    func showBlurhash(_ hash: String) {
        // Generate blurhash image
        blurhashView.image = UIImage(blurHash: hash, size: CGSize(width: 32, height: 32))
        blurhashView.alpha = 1
    }
    
    func showImage(_ image: UIImage, animated: Bool) {
        imageView.image = image
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.blurhashView.alpha = 0
            }
        } else {
            blurhashView.alpha = 0
        }
    }
    
    func showHeartAnimation() {
        heartImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        heartImageView.alpha = 1
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.heartImageView.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5) {
                self.heartImageView.alpha = 0
            }
        }
    }
}
```

---

## Testing Strategy

```swift
// MARK: - Unit Tests

class FeedViewModelTests: XCTestCase {
    
    var sut: FeedViewModel!
    var mockFeedManager: MockFeedManager!
    var mockAnalytics: MockAnalyticsService!
    
    override func setUp() {
        super.setUp()
        mockFeedManager = MockFeedManager()
        mockAnalytics = MockAnalyticsService()
        sut = FeedViewModel(feedManager: mockFeedManager, analyticsService: mockAnalytics)
    }
    
    override func tearDown() {
        sut = nil
        mockFeedManager = nil
        mockAnalytics = nil
        super.tearDown()
    }
    
    func testLoadInitialFeed_Success() async {
        // Given
        let expectedPosts = [Post.mock(), Post.mock()]
        mockFeedManager.mockFeedResponse = FeedResponse(posts: expectedPosts.map { .post($0) }, cursor: "next", hasMore: true, refreshInterval: 300, serverTime: Date())
        
        // When
        await sut.loadInitialFeed()
        
        // Then
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.state, .loaded)
    }
    
    func testLoadInitialFeed_Error() async {
        // Given
        mockFeedManager.shouldFail = true
        
        // When
        await sut.loadInitialFeed()
        
        // Then
        XCTAssertTrue(sut.items.isEmpty)
        if case .error = sut.state {
            // Expected
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testToggleLike_OptimisticUpdate() async {
        // Given
        let post = Post.mock(isLiked: false)
        mockFeedManager.mockFeedResponse = FeedResponse(posts: [.post(post)], cursor: nil, hasMore: false, refreshInterval: 300, serverTime: Date())
        await sut.loadInitialFeed()
        
        // When
        sut.toggleLike(post.id)
        
        // Then - Optimistic update should happen immediately
        await Task.yield()
        
        if case .post(let updatedPost) = sut.items.first {
            XCTAssertTrue(updatedPost.interactions.isLiked)
        } else {
            XCTFail("Expected post")
        }
    }
    
    func testInfiniteScroll_LoadsMoreAtThreshold() async {
        // Given
        let posts = (0..<20).map { _ in Post.mock() }
        mockFeedManager.mockFeedResponse = FeedResponse(posts: posts.map { .post($0) }, cursor: "next", hasMore: true, refreshInterval: 300, serverTime: Date())
        await sut.loadInitialFeed()
        
        // When - Simulate scrolling to threshold
        let thresholdItem = sut.items[14]  // 5 from end
        sut.onItemAppear(thresholdItem)
        
        // Then
        await Task.yield()
        XCTAssertTrue(mockFeedManager.loadMoreCalled)
    }
}

// MARK: - Integration Tests

class FeedIntegrationTests: XCTestCase {
    
    func testFeedLoadAndScroll() async throws {
        // Setup real dependencies with test configuration
        let repository = FeedRepository(baseURL: TestConfig.baseURL)
        let feedManager = FeedManager(repository: repository)
        let viewModel = FeedViewModel(feedManager: feedManager)
        
        // Load feed
        await viewModel.loadInitialFeed()
        
        XCTAssertFalse(viewModel.items.isEmpty)
        XCTAssertEqual(viewModel.state, .loaded)
        
        // Scroll and load more
        if let lastItem = viewModel.items.last {
            viewModel.onItemAppear(lastItem)
        }
        
        // Wait for load more
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        XCTAssertGreaterThan(viewModel.items.count, 20)
    }
}

// MARK: - Performance Tests

class FeedPerformanceTests: XCTestCase {
    
    func testScrollPerformance() {
        let viewModel = FeedViewModel()
        let items = (0..<100).map { _ in FeedItem.post(Post.mock()) }
        
        measure {
            // Simulate rapid scrolling
            for item in items {
                viewModel.onItemAppear(item)
            }
        }
    }
    
    func testImageLoadingPerformance() async {
        let urls = (0..<50).map { _ in URL(string: "https://example.com/image\(UUID().uuidString).jpg")! }
        
        let start = CFAbsoluteTimeGetCurrent()
        
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    _ = try? await ImagePipeline.shared.loadImage(from: url)
                }
            }
        }
        
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        XCTAssertLessThan(elapsed, 5.0, "Image loading took too long")
    }
}

// MARK: - Mocks

class MockFeedManager: FeedManager {
    var mockFeedResponse: FeedResponse?
    var shouldFail = false
    var loadMoreCalled = false
    
    override func loadInitialFeed() async {
        if shouldFail {
            state = .error(NSError(domain: "Test", code: -1))
            return
        }
        
        if let response = mockFeedResponse {
            items = response.posts
            state = .loaded
        }
    }
    
    override func loadMore() async {
        loadMoreCalled = true
    }
}

class MockAnalyticsService: AnalyticsService {
    var trackedEvents: [(String, [String: Any])] = []
    
    override func trackImpression(postId: String) {
        trackedEvents.append(("impression", ["post_id": postId]))
    }
}

extension Post {
    static func mock(isLiked: Bool = false) -> Post {
        Post(
            id: UUID().uuidString,
            author: UserSummary(id: "user1", username: "testuser", displayName: "Test User", avatarURL: URL(string: "https://example.com/avatar.jpg")!, isVerified: false, isFollowing: true, hasActiveStory: false),
            content: .singleMedia(MediaItem(id: "media1", type: .image, aspectRatio: 1.0, urls: MediaURLs(thumbnail: URL(string: "https://example.com/thumb.jpg")!, small: URL(string: "https://example.com/small.jpg")!, medium: URL(string: "https://example.com/medium.jpg")!, large: URL(string: "https://example.com/large.jpg")!, original: URL(string: "https://example.com/original.jpg")!), blurhash: nil, altText: nil, taggedUsers: [], productTags: [])),
            engagement: EngagementMetrics(likesCount: 100, commentsCount: 10, sharesCount: 5, savesCount: 20, viewsCount: nil, likedByFollowing: []),
            metadata: PostMetadata(createdAt: Date(), editedAt: nil, location: nil, caption: Caption(text: "Test caption", mentions: [], hashtags: [], truncatedLength: 100), isSponsored: false, isPinned: false, commentsDisabled: false, likesHidden: false),
            interactions: UserInteractions(isLiked: isLiked, isSaved: false, likedAt: nil, savedAt: nil)
        )
    }
}
```

---

## Interview Discussion Points

### Common Interview Questions

#### 1. "How would you design the feed to handle millions of users?"

**Key Points:**
- Client-side: Focus on efficient caching, prefetching, cell recycling
- Feed generation happens server-side (fan-out on write vs read)
- Cursor-based pagination for consistency
- CDN for media delivery
- Edge caching for feed data

#### 2. "How do you ensure smooth scrolling at 60 FPS?"

**Key Points:**
- Avoid main thread blocking (async image loading)
- Cell reuse with proper `prepareForReuse()`
- Pre-calculated cell heights
- Image decoding on background thread
- Memory pressure management

#### 3. "How do you handle offline mode?"

**Key Points:**
- Multi-layer caching (memory → disk → database)
- Pending action queue for interactions
- Network state monitoring
- Conflict resolution strategy
- Sync on reconnection

#### 4. "How do you optimize battery consumption?"

**Key Points:**
- Batch network requests
- Reduce background refresh frequency
- Coalesce location updates
- Efficient image formats (HEIC/WebP)
- Cancel unnecessary operations

#### 5. "How would you implement real-time updates?"

**Key Points:**
- WebSocket for push updates
- Fallback to polling
- Optimistic UI updates
- Conflict resolution
- Connection state management

### Trade-off Discussions

| Decision | Option A | Option B | Recommendation |
|----------|----------|----------|----------------|
| Feed freshness | Always fetch | Cache-first | Cache-first with background refresh |
| Image quality | High resolution | Adaptive | Adaptive based on connection |
| Pagination | Offset-based | Cursor-based | Cursor for consistency |
| State management | Redux pattern | MVVM | MVVM for mobile |
| Offline sync | Immediate | Batch | Batch for efficiency |

### System Design Checklist

```
✅ Requirements Analysis
  - Functional requirements defined
  - Non-functional requirements quantified
  - Constraints identified

✅ Architecture
  - High-level diagram
  - Component responsibilities
  - Data flow documented

✅ Data Models
  - Core entities defined
  - Database schema
  - API contracts

✅ Key Components
  - Feed generation
  - Caching strategy
  - Image pipeline
  - Pagination

✅ Advanced Topics
  - Real-time updates
  - Offline support
  - Performance optimization

✅ Testing
  - Unit tests
  - Integration tests
  - Performance tests
```

---

## Summary

The Instagram feed represents a complex mobile system design challenge that requires careful consideration of:

1. **Data Management**: Multi-layer caching, efficient pagination, and optimistic updates
2. **Performance**: 60 FPS scrolling, efficient memory management, background processing
3. **Reliability**: Offline support, error recovery, conflict resolution
4. **Scalability**: CDN usage, efficient API design, client-side optimization
5. **User Experience**: Instant feedback, smooth animations, fresh content

The key to a successful feed implementation is balancing these concerns while maintaining code quality and testability.
