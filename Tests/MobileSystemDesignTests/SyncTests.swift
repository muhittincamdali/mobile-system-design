import Foundation
import Testing
@testable import MobileSystemDesign

@Suite("HybridLogicalClock")
struct HybridLogicalClockTests {
    let base = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("follows the wall clock when it moves forward")
    func followsWallClock() throws {
        var clock = HybridLogicalClock(node: "a")
        let first = try clock.tick(physicalTime: base)
        let second = try clock.tick(physicalTime: base.addingTimeInterval(1))
        #expect(first == HybridTimestamp(milliseconds: 1_800_000_000_000, counter: 0, node: "a"))
        #expect(second == HybridTimestamp(milliseconds: 1_800_000_001_000, counter: 0, node: "a"))
    }

    @Test("never goes backwards when the wall clock does")
    func monotonic() throws {
        var clock = HybridLogicalClock(node: "a")
        let first = try clock.tick(physicalTime: base)
        let second = try clock.tick(physicalTime: base.addingTimeInterval(-3_600))
        let third = try clock.tick(physicalTime: base)
        #expect(first < second && second < third)
        #expect(third.milliseconds == first.milliseconds)
        #expect(third.counter == 2)
    }

    @Test("orders a received event after the remote timestamp")
    func receiveOrdersAfterRemote() throws {
        var clock = HybridLogicalClock(node: "a")
        _ = try clock.tick(physicalTime: base)
        let remote = HybridTimestamp(milliseconds: 1_800_000_000_500, counter: 4, node: "b")
        let merged = try clock.receive(remote, physicalTime: base)
        #expect(merged > remote)
        #expect(merged == HybridTimestamp(milliseconds: remote.milliseconds, counter: 5, node: "a"))
        let next = try clock.tick(physicalTime: base)
        #expect(next > merged)
    }

    @Test("takes the larger counter when both clocks are on the same millisecond")
    func receiveSameMillisecond() throws {
        var clock = HybridLogicalClock(node: "a")
        for _ in 0..<3 { _ = try clock.tick(physicalTime: base) }  // counter 2
        let remote = HybridTimestamp(milliseconds: 1_800_000_000_000, counter: 9, node: "b")
        let fromRemote = try clock.receive(remote, physicalTime: base)
        #expect(fromRemote.counter == 10)
        let older = HybridTimestamp(milliseconds: 1_800_000_000_000, counter: 1, node: "c")
        let fromOlder = try clock.receive(older, physicalTime: base)
        #expect(fromOlder.counter == 11)
    }

    @Test("a newer wall clock resets the counter")
    func receiveWithNewerWallClock() throws {
        var clock = HybridLogicalClock(node: "a")
        let remote = HybridTimestamp(milliseconds: 1_000, counter: 7, node: "b")
        let merged = try clock.receive(remote, physicalTime: base)
        #expect(merged == HybridTimestamp(milliseconds: 1_800_000_000_000, counter: 0, node: "a"))
    }

    @Test("rejects a remote timestamp too far in the future and stays unchanged")
    func rejectsDrift() throws {
        var clock = HybridLogicalClock(node: "a", maximumDrift: .seconds(60))
        let before = try clock.tick(physicalTime: base)
        let future = HybridTimestamp(milliseconds: 1_800_000_060_001, counter: 0, node: "evil")
        #expect(throws: HybridLogicalClock.ClockError.driftExceeded(remote: future, localMilliseconds: 1_800_000_000_000)) {
            try clock.receive(future, physicalTime: base)
        }
        #expect(clock.latest == before)
        let edge = HybridTimestamp(milliseconds: 1_800_000_060_000, counter: 0, node: "b")
        let accepted = try clock.receive(edge, physicalTime: base)
        #expect(accepted > edge)
    }

    @Test("a huge allowed drift does not overflow")
    func hugeDrift() throws {
        var clock = HybridLogicalClock(node: "a", maximumDrift: .seconds(Int64.max))
        let remote = HybridTimestamp(milliseconds: .max - 1, counter: 0, node: "b")
        let merged = try clock.receive(remote, physicalTime: base)
        #expect(merged.milliseconds == .max - 1)
    }

    @Test("an exhausted counter moves to the next millisecond")
    func counterOverflow() throws {
        var clock = HybridLogicalClock(node: "a")
        let remote = HybridTimestamp(milliseconds: 1_800_000_000_000, counter: .max, node: "b")
        let merged = try clock.receive(remote, physicalTime: base)
        #expect(merged == HybridTimestamp(milliseconds: 1_800_000_000_001, counter: 0, node: "a"))
        #expect(merged > remote)
    }

    @Test("throws at the last representable timestamp instead of repeating it")
    func exhausted() throws {
        var clock = HybridLogicalClock(node: "a", maximumDrift: .seconds(Int64.max))
        let last = HybridTimestamp(milliseconds: .max, counter: .max - 1, node: "b")
        let merged = try clock.receive(last, physicalTime: base)
        #expect(merged == HybridTimestamp(milliseconds: .max, counter: .max, node: "a"))

        #expect(throws: HybridLogicalClock.ClockError.exhausted) { try clock.tick(physicalTime: base) }
        #expect(throws: HybridLogicalClock.ClockError.exhausted) { try clock.receive(last, physicalTime: base) }
        #expect(clock.latest == merged)
    }

    @Test("dates that do not fit in milliseconds throw instead of trapping",
          arguments: [Double.nan, .infinity, -.infinity, 1e300, -1e300])
    func invalidPhysicalTime(seconds: Double) {
        let date = Date(timeIntervalSince1970: seconds)
        #expect(HybridLogicalClock.milliseconds(of: date) == nil)
        var clock = HybridLogicalClock(node: "a")
        #expect(throws: HybridLogicalClock.ClockError.invalidPhysicalTime) { try clock.tick(physicalTime: date) }
        let remote = HybridTimestamp(milliseconds: 0, counter: 0, node: "b")
        #expect(throws: HybridLogicalClock.ClockError.invalidPhysicalTime) { try clock.receive(remote, physicalTime: date) }
    }

    @Test("rejects remote node ids that are empty or too long", arguments: [0, 129, 1_000_000])
    func rejectsInvalidNode(length: Int) throws {
        var clock = HybridLogicalClock(node: "a")
        let before = try clock.tick(physicalTime: base)
        let remote = HybridTimestamp(milliseconds: 1, counter: 0, node: String(repeating: "x", count: length))
        #expect(throws: HybridLogicalClock.ClockError.invalidNode) { try clock.receive(remote, physicalTime: base) }
        #expect(clock.latest == before)
        let longest = HybridTimestamp(milliseconds: 1, counter: 0, node: String(repeating: "é", count: 64))
        let accepted = try clock.receive(longest, physicalTime: base)
        #expect(accepted > before)
    }

    @Test("dates before 1970 convert to negative milliseconds")
    func negativeMilliseconds() {
        #expect(HybridLogicalClock.milliseconds(of: Date(timeIntervalSince1970: -1.5)) == -1_500)
        #expect(HybridLogicalClock.milliseconds(of: Date(timeIntervalSince1970: -0.0001)) == -1)
    }

    @Test("timestamps on the same millisecond and counter order by node")
    func tieBreak() {
        let a = HybridTimestamp(milliseconds: 5, counter: 1, node: "a")
        let b = HybridTimestamp(milliseconds: 5, counter: 1, node: "b")
        #expect(a < b)
        #expect(b.description == "5.1@b")
    }
}

@Suite("LWWRegister")
struct LWWRegisterTests {
    func stamp(_ ms: Int64, _ counter: UInt32 = 0, _ node: String = "a") -> HybridTimestamp {
        HybridTimestamp(milliseconds: ms, counter: counter, node: node)
    }

    @Test("keeps the later write")
    func laterWins() {
        var register = LWWRegister("draft", timestamp: stamp(10))
        let newer = register.set("final", timestamp: stamp(11))
        let older = register.set("stale", timestamp: stamp(9))
        let equal = register.set("same", timestamp: stamp(11))
        #expect(newer && !older && !equal)
        #expect(register.value == "final")
    }

    @Test("merging converges whatever the order, and is idempotent")
    func convergence() {
        let edits = [
            LWWRegister("phone", timestamp: stamp(100, 0, "phone")),
            LWWRegister("tablet", timestamp: stamp(100, 0, "tablet")),
            LWWRegister("web", timestamp: stamp(99, 5, "web"))
        ]
        let orders = [[0, 1, 2], [2, 1, 0], [1, 0, 2], [1, 2, 0, 1, 0]]
        let results = orders.map { order -> LWWRegister<String> in
            var register = LWWRegister("initial", timestamp: stamp(0))
            for index in order { register.merge(edits[index]) }
            return register
        }
        #expect(Set(results.map(\.value)) == ["tablet"])
    }

    @Test("round-trips through JSON")
    func codable() throws {
        let register = LWWRegister(42, timestamp: stamp(7, 3, "node"))
        let data = try JSONEncoder().encode(register)
        #expect(try JSONDecoder().decode(LWWRegister<Int>.self, from: data) == register)
    }
}
