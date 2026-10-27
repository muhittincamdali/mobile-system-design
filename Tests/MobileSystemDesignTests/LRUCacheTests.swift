import Foundation
import Testing
@testable import MobileSystemDesign

@Suite("LRUCache")
struct LRUCacheTests {
    let start = Date(timeIntervalSince1970: 1_000_000)

    @Test("evicts the least recently used value when the count limit is reached")
    func evictsLeastRecentlyUsed() {
        var cache = LRUCache<String, Int>(countLimit: 2)
        cache.insert(1, forKey: "a")
        cache.insert(2, forKey: "b")
        #expect(cache.value(forKey: "a") == 1) // "a" is now the newest
        let evicted = cache.insert(3, forKey: "c")
        #expect(evicted == ["b"])
        #expect(cache.keys == ["c", "a"])
        #expect(cache.value(forKey: "b") == nil)
    }

    @Test("peek does not change the eviction order")
    func peekKeepsOrder() {
        var cache = LRUCache<String, Int>(countLimit: 2)
        cache.insert(1, forKey: "a")
        cache.insert(2, forKey: "b")
        #expect(cache.peek("a") == 1)
        #expect(cache.insert(3, forKey: "c") == ["a"])
    }

    @Test("replacing a value updates its cost and recency")
    func replaceUpdatesCost() {
        var cache = LRUCache<String, String>(countLimit: 3, costLimit: 10)
        cache.insert("x", forKey: "a", cost: 6)
        cache.insert("y", forKey: "b", cost: 2)
        cache.insert("z", forKey: "a", cost: 1)
        #expect(cache.totalCost == 3)
        #expect(cache.count == 2)
        #expect(cache.keys == ["a", "b"])
        #expect(cache.value(forKey: "a") == "z")
    }

    @Test("evicts as many old values as the cost limit needs")
    func evictsByCost() {
        var cache = LRUCache<Int, String>(countLimit: 10, costLimit: 10)
        for key in 0..<5 { cache.insert("v\(key)", forKey: key, cost: 2) }
        #expect(cache.totalCost == 10)
        let evicted = cache.insert("big", forKey: 99, cost: 7)
        #expect(evicted == [0, 1, 2, 3])
        #expect(cache.totalCost == 9)
        #expect(cache.keys == [99, 4])
    }

    @Test("a value above the cost limit is not stored and removes the stale value")
    func oversizedValueRemovesStale() {
        var cache = LRUCache<String, String>(countLimit: 5, costLimit: 10)
        cache.insert("old", forKey: "a", cost: 4)
        cache.insert("keep", forKey: "b", cost: 4)
        let evicted = cache.insert("huge", forKey: "a", cost: 11)
        #expect(evicted.isEmpty)
        #expect(cache.value(forKey: "a") == nil)
        #expect(cache.value(forKey: "b") == "keep")
        #expect(cache.totalCost == 4)
    }

    @Test("costs near Int.max do not overflow the total")
    func costsNearIntMax() {
        var cache = LRUCache<Int, Int>(countLimit: 10)
        cache.insert(1, forKey: 1, cost: .max)
        let evicted = cache.insert(2, forKey: 2, cost: .max)
        #expect(evicted == [1])
        #expect(cache.totalCost == .max)
        cache.insert(3, forKey: 3, cost: 1)
        #expect(cache.keys == [3])
        #expect(cache.totalCost == 1)
    }

    @Test("negative costs count as zero")
    func negativeCost() {
        var cache = LRUCache<Int, Int>(countLimit: 3, costLimit: 5)
        cache.insert(1, forKey: 1, cost: -100)
        #expect(cache.totalCost == 0)
        cache.insert(2, forKey: 2, cost: 5)
        #expect(cache.count == 2)
    }

    @Test("invalid limits are clamped instead of trapping", arguments: [-5, 0])
    func zeroOrNegativeCountLimitDisables(limit: Int) {
        var cache = LRUCache<Int, Int>(countLimit: limit, costLimit: -1)
        #expect(cache.countLimit == 0)
        #expect(cache.costLimit == 0)
        cache.insert(1, forKey: 1)
        #expect(cache.isEmpty)
    }

    @Test("values expire after the time to live", arguments: [10.0, 0.001])
    func expiry(ttl: TimeInterval) {
        var cache = LRUCache<String, Int>(countLimit: 5, timeToLive: ttl)
        cache.insert(1, forKey: "a", now: start)
        #expect(cache.value(forKey: "a", now: start.addingTimeInterval(ttl / 2)) == 1)
        #expect(cache.peek("a", now: start.addingTimeInterval(ttl)) == nil)
        #expect(cache.count == 1) // peek leaves the expired value in place
        #expect(cache.value(forKey: "a", now: start.addingTimeInterval(ttl)) == nil)
        #expect(cache.isEmpty)
    }

    @Test("a time to live that is not a positive finite number is ignored", arguments: [Double.nan, .infinity, -1, 0])
    func invalidTimeToLive(ttl: Double) {
        var cache = LRUCache<String, Int>(countLimit: 5, timeToLive: ttl)
        #expect(cache.timeToLive == nil)
        cache.insert(1, forKey: "a", now: start)
        #expect(cache.value(forKey: "a", now: .distantFuture) == 1)
    }

    @Test("removeExpired removes only the expired values")
    func removeExpired() {
        var cache = LRUCache<String, Int>(countLimit: 5, costLimit: 100, timeToLive: 60)
        cache.insert(1, forKey: "old", cost: 10, now: start)
        cache.insert(2, forKey: "new", cost: 20, now: start.addingTimeInterval(50))
        #expect(cache.removeExpired(now: start.addingTimeInterval(70)) == 1)
        #expect(cache.keys == ["new"])
        #expect(cache.totalCost == 20)
    }

    @Test("trim evicts from the oldest end down to the target cost")
    func trim() {
        var cache = LRUCache<Int, Int>(countLimit: 10, costLimit: 100)
        for key in 1...4 { cache.insert(key, forKey: key, cost: 10) }
        _ = cache.value(forKey: 1)
        #expect(cache.trim(toCost: 15) == [2, 3, 4])
        #expect(cache.keys == [1])
        #expect(cache.trim(toCost: -3) == [1])
        #expect(cache.isEmpty)
    }

    @Test("slots are reused, and the list stays consistent after many operations")
    func randomizedAgainstReference() {
        var cache = LRUCache<Int, Int>(countLimit: 8, costLimit: 40)
        var reference: [(key: Int, value: Int, cost: Int)] = [] // newest first
        var generator = SplitMix64(seed: 42)

        for step in 0..<5_000 {
            let key = Int(generator.next() % 20)
            switch generator.next() % 3 {
            case 0:
                let cost = Int(generator.next() % 12)
                cache.insert(step, forKey: key, cost: cost)
                reference.removeAll { $0.key == key }
                if cost <= 40 {
                    while reference.count >= 8 || reference.reduce(0, { $0 + $1.cost }) > 40 - cost {
                        reference.removeLast()
                    }
                    reference.insert((key, step, cost), at: 0)
                }
            case 1:
                let expected = reference.firstIndex { $0.key == key }
                #expect(cache.value(forKey: key) == expected.map { reference[$0].value })
                if let expected { reference.insert(reference.remove(at: expected), at: 0) }
            default:
                cache.removeValue(forKey: key)
                reference.removeAll { $0.key == key }
            }
            #expect(cache.keys == reference.map(\.key))
            #expect(cache.totalCost == reference.reduce(0) { $0 + $1.cost })
        }
    }
}

/// A small deterministic random number generator for repeatable randomized tests.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
