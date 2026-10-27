import Foundation

/// An in-memory cache that evicts the least recently used values first.
///
/// The cache keeps at most ``countLimit`` values whose costs add up to at most ``costLimit``.
/// Reading or writing a value makes it the most recently used one. With a ``timeToLive``, a value
/// also expires that long after it was written; an expired value is never returned and is
/// removed the next time the cache touches it.
///
/// Every operation is O(1) except ``removeExpired(now:)`` and ``trim(toCost:)``, which walk
/// the values from the least recently used end.
///
/// `LRUCache` is a value type and is not synchronized. Keep it inside an actor, or behind a
/// lock, when several tasks share it:
///
/// ```swift
/// actor ThumbnailStore {
///     private var cache = LRUCache<URL, Data>(countLimit: 200, costLimit: 20_000_000)
///
///     func thumbnail(for url: URL) -> Data? { cache.value(forKey: url) }
///     func store(_ data: Data, for url: URL) { cache.insert(data, forKey: url, cost: data.count) }
/// }
/// ```
public struct LRUCache<Key: Hashable, Value> {
    fileprivate struct Entry {
        var key: Key
        var value: Value
        var cost: Int
        var expiresAt: Date?
        var newer: Int?
        var older: Int?
    }

    /// The largest number of values the cache keeps. Zero disables the cache.
    public let countLimit: Int
    /// The largest total cost of the values the cache keeps.
    public let costLimit: Int
    /// How long a value stays valid after it is written, in seconds; `nil` keeps values until
    /// they are evicted.
    public let timeToLive: TimeInterval?

    private var slots: [Entry?] = []
    private var freeSlots: [Int] = []
    private var index: [Key: Int] = [:]
    private var newest: Int?
    private var oldest: Int?

    /// The total cost of the values in the cache.
    public private(set) var totalCost = 0

    /// Creates an empty cache.
    ///
    /// The limits can come from remote configuration, so out-of-range values are clamped rather
    /// than trapping: a negative `countLimit` or `costLimit` becomes zero, and a `timeToLive`
    /// that is not a positive, finite number of seconds is ignored.
    ///
    /// - Parameters:
    ///   - countLimit: The largest number of values to keep.
    ///   - costLimit: The largest total cost of the values to keep. The default has no limit.
    ///   - timeToLive: Seconds after which a written value expires; `nil` for no expiry.
    public init(countLimit: Int, costLimit: Int = .max, timeToLive: TimeInterval? = nil) {
        self.countLimit = max(0, countLimit)
        self.costLimit = max(0, costLimit)
        if let timeToLive, timeToLive.isFinite, timeToLive > 0 {
            self.timeToLive = timeToLive
        } else {
            self.timeToLive = nil
        }
    }

    /// The number of values in the cache, including expired values not yet removed.
    public var count: Int { index.count }

    /// Whether the cache holds no values.
    public var isEmpty: Bool { index.isEmpty }

    /// The keys from the most to the least recently used.
    public var keys: [Key] {
        var result: [Key] = []
        result.reserveCapacity(index.count)
        var cursor = newest
        while let slot = cursor, let entry = slots[slot] {
            result.append(entry.key)
            cursor = entry.older
        }
        return result
    }

    /// Returns the value for `key` and marks it as the most recently used, or `nil` when there
    /// is no value or it has expired.
    public mutating func value(forKey key: Key, now: Date = Date()) -> Value? {
        guard let slot = index[key], let entry = slots[slot] else { return nil }
        if let expiresAt = entry.expiresAt, expiresAt <= now {
            remove(slot: slot)
            return nil
        }
        moveToNewest(slot)
        return entry.value
    }

    /// Returns the value for `key` without changing the eviction order.
    public func peek(_ key: Key, now: Date = Date()) -> Value? {
        guard let slot = index[key], let entry = slots[slot] else { return nil }
        if let expiresAt = entry.expiresAt, expiresAt <= now { return nil }
        return entry.value
    }

    /// Stores `value` for `key` as the most recently used value and evicts the least recently
    /// used values until the cache is within its limits again.
    ///
    /// A value whose cost alone is above ``costLimit`` is not stored, and an older value for the
    /// same key is removed: keeping the stale value would return outdated data.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key to store it under.
    ///   - cost: The value's cost, for example its size in bytes. Negative costs count as zero.
    ///   - now: The current time, used to compute the expiry date.
    /// - Returns: The keys that were removed to make room, oldest first. It does not include
    ///   `key` itself.
    @discardableResult
    public mutating func insert(_ value: Value, forKey key: Key, cost: Int = 0, now: Date = Date()) -> [Key] {
        let cost = max(0, cost)
        if let slot = index[key] { remove(slot: slot) }
        guard countLimit > 0, cost <= costLimit else { return [] }

        // Evict before inserting: `totalCost + cost` then never exceeds `costLimit`, so the sum
        // cannot overflow even with costs near `Int.max`.
        var evicted: [Key] = []
        while index.count >= countLimit || totalCost > costLimit - cost, let victim = oldest {
            if let key = slots[victim]?.key { evicted.append(key) }
            remove(slot: victim)
        }

        let expiresAt = timeToLive.map { now.addingTimeInterval($0) }
        let entry = Entry(key: key, value: value, cost: cost, expiresAt: expiresAt, newer: nil, older: newest)
        let slot: Int
        if let free = freeSlots.popLast() {
            slot = free
            slots[slot] = entry
        } else {
            slot = slots.count
            slots.append(entry)
        }
        if let previous = newest { slots[previous]?.newer = slot }
        newest = slot
        if oldest == nil { oldest = slot }
        index[key] = slot
        totalCost += cost
        return evicted
    }

    /// Removes and returns the value for `key`.
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let slot = index[key], let entry = slots[slot] else { return nil }
        remove(slot: slot)
        return entry.value
    }

    /// Removes every value.
    public mutating func removeAll() {
        slots.removeAll()
        freeSlots.removeAll()
        index.removeAll()
        newest = nil
        oldest = nil
        totalCost = 0
    }

    /// Removes the values that have expired by `now`.
    ///
    /// - Returns: The number of values removed.
    @discardableResult
    public mutating func removeExpired(now: Date = Date()) -> Int {
        guard timeToLive != nil else { return 0 }
        var removed = 0
        var cursor = oldest
        while let slot = cursor, let entry = slots[slot] {
            cursor = entry.newer
            if let expiresAt = entry.expiresAt, expiresAt <= now {
                remove(slot: slot)
                removed += 1
            }
        }
        return removed
    }

    /// Evicts the least recently used values until the total cost is at most `targetCost`.
    ///
    /// Call it when the system reports memory pressure, for example with half of
    /// ``costLimit``.
    ///
    /// - Returns: The keys that were removed, oldest first.
    @discardableResult
    public mutating func trim(toCost targetCost: Int) -> [Key] {
        let target = max(0, targetCost)
        var evicted: [Key] = []
        while totalCost > target, let victim = oldest {
            if let key = slots[victim]?.key { evicted.append(key) }
            remove(slot: victim)
        }
        return evicted
    }

    private mutating func moveToNewest(_ slot: Int) {
        guard newest != slot else { return }
        unlink(slot)
        slots[slot]?.older = newest
        slots[slot]?.newer = nil
        if let previous = newest { slots[previous]?.newer = slot }
        newest = slot
        if oldest == nil { oldest = slot }
    }

    private mutating func unlink(_ slot: Int) {
        guard let entry = slots[slot] else { return }
        if let newer = entry.newer { slots[newer]?.older = entry.older } else { newest = entry.older }
        if let older = entry.older { slots[older]?.newer = entry.newer } else { oldest = entry.newer }
    }

    private mutating func remove(slot: Int) {
        guard let entry = slots[slot] else { return }
        unlink(slot)
        index[entry.key] = nil
        totalCost -= entry.cost
        slots[slot] = nil
        freeSlots.append(slot)
    }
}

extension LRUCache: Sendable where Key: Sendable, Value: Sendable {}
extension LRUCache.Entry: Sendable where Key: Sendable, Value: Sendable {}
