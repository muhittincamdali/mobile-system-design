import Foundation
import Testing
@testable import MobileSystemDesign

/// A clock that only moves when the test moves it.
final class ManualClock: @unchecked Sendable {
    private let lock = NSLock()
    private var current = ContinuousClock.now

    var now: ContinuousClock.Instant { lock.withLock { current } }
    func advance(by duration: Duration) { lock.withLock { current += duration } }
    var reader: @Sendable () -> ContinuousClock.Instant { { [self] in now } }
}

struct ServerDown: Error {}

@Suite("CircuitBreaker")
struct CircuitBreakerTests {
    let clock = ManualClock()

    func makeBreaker(threshold: Int = 3, open: Duration = .seconds(10), probes: Int = 1) -> CircuitBreaker {
        CircuitBreaker(
            configuration: .init(failureThreshold: threshold, openDuration: open, halfOpenProbeLimit: probes),
            now: clock.reader
        )
    }

    func fail(_ breaker: CircuitBreaker, times: Int) async {
        for _ in 0..<times {
            _ = try? await breaker.run { () async throws -> Int in throw ServerDown() }
        }
    }

    @Test("opens after the failure threshold and fails fast")
    func opensAfterThreshold() async throws {
        let breaker = makeBreaker()
        await fail(breaker, times: 2)
        #expect(await breaker.state == .closed(failures: 2))
        await fail(breaker, times: 1)
        #expect(await breaker.state == .open(until: clock.now + .seconds(10)))

        var ran = false
        await #expect(throws: CircuitBreakerError.open(retryAfter: .seconds(10))) {
            try await breaker.run { ran = true }
        }
        #expect(!ran)
    }

    @Test("a success resets the consecutive failure count")
    func successResetsCount() async throws {
        let breaker = makeBreaker()
        await fail(breaker, times: 2)
        try await breaker.run {}
        await fail(breaker, times: 2)
        #expect(await breaker.state == .closed(failures: 2))
    }

    @Test("lets one probe through after the open duration and closes on success")
    func halfOpenProbeSucceeds() async throws {
        let breaker = makeBreaker()
        await fail(breaker, times: 3)
        clock.advance(by: .seconds(10))

        let permit = try await breaker.acquire()
        #expect(await breaker.state == .halfOpen(probesInFlight: 1))
        await #expect(throws: CircuitBreakerError.open(retryAfter: .zero)) { try await breaker.acquire() }
        await breaker.recordSuccess(permit)
        #expect(await breaker.state == .closed(failures: 0))
    }

    @Test("a failed probe opens the breaker again")
    func halfOpenProbeFails() async throws {
        let breaker = makeBreaker()
        await fail(breaker, times: 3)
        clock.advance(by: .seconds(11))
        await fail(breaker, times: 1)
        #expect(await breaker.state == .open(until: clock.now + .seconds(10)))
    }

    @Test("results of calls from before a state change are ignored")
    func staleResultsIgnored() async throws {
        let breaker = makeBreaker(threshold: 1)
        let slowCall = try await breaker.acquire()        // started while closed
        await fail(breaker, times: 1)                      // opens
        clock.advance(by: .seconds(10))
        let probe = try await breaker.acquire()            // half-open
        await breaker.recordSuccess(probe)                 // closes
        await breaker.recordFailure(slowCall)              // late failure of the old call
        #expect(await breaker.state == .closed(failures: 0))
    }

    @Test("errors that do not describe server health do not count")
    func ignoredErrors() async throws {
        let breaker = makeBreaker(threshold: 1)
        _ = try? await breaker.run { () async throws -> Int in throw HTTPStatusError(statusCode: 404) }
        _ = try? await breaker.run { () async throws -> Int in throw CancellationError() }
        _ = try? await breaker.run { () async throws -> Int in throw URLError(.cancelled) }
        #expect(await breaker.state == .closed(failures: 0))
        _ = try? await breaker.run { () async throws -> Int in throw HTTPStatusError(statusCode: 503) }
        #expect(await breaker.state == .open(until: clock.now + .seconds(10)))
    }

    @Test("a cancelled probe releases its slot")
    func cancelledProbeReleasesSlot() async throws {
        let breaker = makeBreaker(threshold: 1)
        await fail(breaker, times: 1)
        clock.advance(by: .seconds(10))
        _ = try? await breaker.run { () async throws -> Int in throw CancellationError() }
        #expect(await breaker.state == .halfOpen(probesInFlight: 0))
        try await breaker.run {}
        #expect(await breaker.state == .closed(failures: 0))
    }

    @Test("several probes may run when configured")
    func probeLimit() async throws {
        let breaker = makeBreaker(threshold: 1, probes: 2)
        await fail(breaker, times: 1)
        clock.advance(by: .seconds(10))
        _ = try await breaker.acquire()
        _ = try await breaker.acquire()
        await #expect(throws: CircuitBreakerError.self) { try await breaker.acquire() }
    }

    @Test("configuration values below the minimum are raised")
    func configurationClamping() {
        let configuration = CircuitBreaker.Configuration(failureThreshold: 0, openDuration: .seconds(-3), halfOpenProbeLimit: -1)
        #expect(configuration.failureThreshold == 1)
        #expect(configuration.openDuration == .zero)
        #expect(configuration.halfOpenProbeLimit == 1)
    }

    @Test("reset closes an open breaker")
    func reset() async throws {
        let breaker = makeBreaker(threshold: 1)
        await fail(breaker, times: 1)
        await breaker.reset()
        try await breaker.run {}
        #expect(await breaker.state == .closed(failures: 0))
    }
}

@Suite("TokenBucket")
struct TokenBucketTests {
    let start = ContinuousClock.now

    @Test("allows a burst up to the capacity, then refills over time")
    func burstAndRefill() {
        var bucket = TokenBucket(capacity: 3, refillPerSecond: 1, now: start)
        var granted = 0
        for _ in 0..<3 where bucket.tryConsume(at: start) { granted += 1 }
        #expect(granted == 3)
        let allowedAgain = bucket.tryConsume(at: start)
        #expect(!allowedAgain)
        #expect(bucket.timeUntilAvailable(at: start) == .seconds(1))
        let allowedEarly = bucket.tryConsume(at: start + .milliseconds(999))
        #expect(!allowedEarly)
        let allowedAfterRefill = bucket.tryConsume(at: start + .seconds(1))
        #expect(allowedAfterRefill)
    }

    @Test("never holds more than its capacity")
    func capsAtCapacity() {
        let bucket = TokenBucket(capacity: 2, refillPerSecond: 100, now: start)
        #expect(bucket.availableTokens(at: start + .seconds(3_600)) == 2)
    }

    @Test("an earlier clock reading does not remove tokens")
    func clockGoingBack() {
        var bucket = TokenBucket(capacity: 2, refillPerSecond: 1, now: start)
        let consumedFirst = bucket.tryConsume(at: start)
        #expect(consumedFirst)
        #expect(bucket.availableTokens(at: start - .seconds(100)) == 1)
    }

    @Test("refuses token counts that are not positive finite numbers", arguments: [0, -1, Double.nan, .infinity])
    func invalidCounts(count: Double) {
        var bucket = TokenBucket(capacity: 5, refillPerSecond: 1, now: start)
        let consumedInvalid = bucket.tryConsume(count, at: start)
        #expect(!consumedInvalid)
        #expect(bucket.timeUntilAvailable(count, at: start) == nil)
        #expect(bucket.availableTokens(at: start) == 5)
    }

    @Test("invalid configuration makes a bucket that refuses everything", arguments: [Double.nan, -2, .infinity])
    func invalidConfiguration(value: Double) {
        var bucket = TokenBucket(capacity: value, refillPerSecond: value, now: start)
        #expect(bucket.capacity == 0)
        #expect(bucket.refillPerSecond == 0)
        let consumedAfterWait = bucket.tryConsume(at: start + .seconds(10))
        #expect(!consumedAfterWait)
    }

    @Test("reports when a request can never be served")
    func neverAvailable() {
        var bucket = TokenBucket(capacity: 2, refillPerSecond: 0, now: start)
        #expect(bucket.timeUntilAvailable(3, at: start) == nil)
        let consumedAll = bucket.tryConsume(2, at: start)
        #expect(consumedAll)
        #expect(bucket.timeUntilAvailable(1, at: start) == nil)
    }

    @Test("fractional costs and rates")
    func fractional() {
        var bucket = TokenBucket(capacity: 1, refillPerSecond: 0.5, now: start)
        let consumedFraction = bucket.tryConsume(0.75, at: start)
        #expect(consumedFraction)
        #expect(bucket.timeUntilAvailable(1, at: start) == .milliseconds(1_500))
    }
}
