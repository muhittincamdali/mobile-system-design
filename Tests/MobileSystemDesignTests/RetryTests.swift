import Foundation
import Testing
@testable import MobileSystemDesign

@Suite("RetryPolicy")
struct RetryPolicyTests {
    @Test("delays grow exponentially and stop at maxDelay")
    func exponentialGrowth() {
        let policy = RetryPolicy(maxAttempts: 10, initialDelay: .milliseconds(100), multiplier: 2, maxDelay: .seconds(1), jitter: .none)
        let delays = (1...6).map { policy.delay(afterAttempt: $0, randomUnit: 0.5) }
        #expect(delays == [.milliseconds(100), .milliseconds(200), .milliseconds(400), .milliseconds(800), .seconds(1), .seconds(1)])
    }

    @Test("full jitter scales the delay by the random unit")
    func fullJitter() {
        let policy = RetryPolicy(initialDelay: .seconds(2), jitter: .full)
        #expect(policy.delay(afterAttempt: 1, randomUnit: 0) == .zero)
        #expect(policy.delay(afterAttempt: 1, randomUnit: 0.25) == .milliseconds(500))
        #expect(policy.delay(afterAttempt: 2, randomUnit: 0.5) == .seconds(2))
    }

    @Test("equal jitter keeps at least half of the delay")
    func equalJitter() {
        let policy = RetryPolicy(initialDelay: .seconds(4), jitter: .equal)
        #expect(policy.delay(afterAttempt: 1, randomUnit: 0) == .seconds(2))
        #expect(policy.delay(afterAttempt: 1, randomUnit: 1) == .seconds(4))
    }

    @Test("a broken random source cannot produce an invalid delay", arguments: [Double.nan, -3, 7, .infinity, -.infinity])
    func randomUnitIsClamped(unit: Double) {
        let policy = RetryPolicy(initialDelay: .seconds(1), maxDelay: .seconds(5), jitter: .full)
        let delay = policy.delay(afterAttempt: 3, randomUnit: unit)
        #expect(delay >= .zero && delay <= .seconds(4))
    }

    @Test("huge attempt numbers stay at maxDelay instead of overflowing", arguments: [64, 1_100, Int.max])
    func hugeAttempts(attempt: Int) {
        let policy = RetryPolicy(initialDelay: .seconds(1), multiplier: 10, maxDelay: .seconds(30), jitter: .none)
        #expect(policy.delay(afterAttempt: attempt, randomUnit: 0) == .seconds(30))
    }

    @Test("attempt numbers below 1 count as the first attempt", arguments: [0, -1, Int.min])
    func lowAttempts(attempt: Int) {
        let policy = RetryPolicy(initialDelay: .seconds(1), jitter: .none)
        #expect(policy.delay(afterAttempt: attempt, randomUnit: 0) == .seconds(1))
    }

    @Test("remote configuration values are clamped")
    func clamping() {
        let policy = RetryPolicy(maxAttempts: Int.max, initialDelay: .seconds(-1), multiplier: .nan, maxDelay: .seconds(-5))
        #expect(policy.maxAttempts == RetryPolicy.attemptLimit)
        #expect(policy.initialDelay == .zero)
        #expect(policy.multiplier == 1)
        #expect(policy.maxDelay == .zero)
        #expect(RetryPolicy(maxAttempts: -2).maxAttempts == 1)
        #expect(RetryPolicy(multiplier: 0.5).multiplier == 1)
        #expect(policy.delay(afterAttempt: 5, randomUnit: 0.9) == .zero)
    }

    @Test("an infinite multiplier means the maximum delay from the second attempt")
    func infiniteMultiplier() {
        let policy = RetryPolicy(initialDelay: .seconds(1), multiplier: .infinity, maxDelay: .seconds(9), jitter: .none)
        #expect(policy.delay(afterAttempt: 1, randomUnit: 0) == .seconds(1))
        #expect(policy.delay(afterAttempt: 2, randomUnit: 0) == .seconds(9))
    }
}

@Suite("RetryAfter")
struct RetryAfterTests {
    let now = Date(timeIntervalSince1970: 1_793_000_000)

    @Test("reads delta seconds")
    func deltaSeconds() {
        #expect(RetryAfter.parse("120") == .seconds(120))
        #expect(RetryAfter.parse("  7 ") == .seconds(7))
        #expect(RetryAfter.parse("0") == .zero)
        #expect(RetryAfter.parse("0000000000000000000000000000005") == .seconds(5))
    }

    @Test("caps very large values at the maximum")
    func capsLargeValues() {
        #expect(RetryAfter.parse("86401") == RetryAfter.maximum)
        #expect(RetryAfter.parse("99999999999999999999999999") == RetryAfter.maximum)
    }

    @Test("rejects values that are not a non-negative integer or a date", arguments: ["", "  ", "-5", "1.5", "1e3", "abc", "１２", "12 34", String(repeating: "1", count: 65)])
    func rejectsInvalid(value: String) {
        #expect(RetryAfter.parse(value, now: now) == nil)
    }

    @Test("reads the three HTTP date formats")
    func httpDates() throws {
        let target = try #require(ISO8601DateFormatter().date(from: "2026-10-27T10:00:30Z"))
        let reference = target.addingTimeInterval(-30)
        #expect(RetryAfter.parse("Tue, 27 Oct 2026 10:00:30 GMT", now: reference) == .seconds(30))
        #expect(RetryAfter.parse("Tuesday, 27-Oct-26 10:00:30 GMT", now: reference) == .seconds(30))
        #expect(RetryAfter.parse("Tue Oct 27 10:00:30 2026", now: reference) == .seconds(30))
    }

    @Test("a date in the past means no wait, and a far date is capped")
    func pastAndFarDates() {
        #expect(RetryAfter.parse("Thu, 01 Jan 1970 00:00:00 GMT", now: now) == .zero)
        #expect(RetryAfter.parse("Fri, 31 Dec 9999 23:59:59 GMT", now: now) == RetryAfter.maximum)
    }

    @Test("HTTPStatusError reads the header from a response")
    func fromResponse() throws {
        let url = try #require(URL(string: "https://example.com/feed"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 503, httpVersion: nil, headerFields: ["Retry-After": "3"]))
        let error = HTTPStatusError(response: response)
        #expect(error == HTTPStatusError(statusCode: 503, retryAfter: .seconds(3)))
        #expect(RetryDecision.classify(error) == .retryAfter(.seconds(3)))
    }
}

@Suite("RetryDecision")
struct RetryDecisionTests {
    @Test("retries the status codes that describe a temporary condition", arguments: [408, 429, 500, 502, 503, 504])
    func retryableStatus(code: Int) {
        #expect(RetryDecision.classify(HTTPStatusError(statusCode: code)) == .retry)
    }

    @Test("does not retry other status codes", arguments: [400, 401, 403, 404, 409, 422, 501, 505])
    func permanentStatus(code: Int) {
        #expect(RetryDecision.classify(HTTPStatusError(statusCode: code)) == .doNotRetry)
    }

    @Test("classifies URL errors")
    func urlErrors() {
        #expect(RetryDecision.classify(URLError(.timedOut)) == .retry)
        #expect(RetryDecision.classify(URLError(.notConnectedToInternet)) == .retry)
        #expect(RetryDecision.classify(URLError(.badURL)) == .doNotRetry)
        #expect(RetryDecision.classify(URLError(.cancelled)) == .doNotRetry)
        #expect(RetryDecision.classify(URLError(.serverCertificateUntrusted)) == .doNotRetry)
    }

    @Test("never retries cancellation or unknown errors")
    func otherErrors() {
        #expect(RetryDecision.classify(CancellationError()) == .doNotRetry)
        #expect(RetryDecision.classify(CocoaError(.fileNoSuchFile)) == .doNotRetry)
    }
}

/// Records the waits a `Retrier` asks for, without waiting.
final class SleepRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [Duration] = []
    var waits: [Duration] { lock.withLock { recorded } }

    var sleep: @Sendable (Duration) async throws -> Void {
        { [self] duration in
            lock.withLock { recorded.append(duration) }
            try Task.checkCancellation()
        }
    }
}

@Suite("Retrier")
struct RetrierTests {
    @Test("returns the first success and waits between failed attempts")
    func succeedsAfterFailures() async throws {
        let sleeper = SleepRecorder()
        let retrier = Retrier(
            policy: RetryPolicy(maxAttempts: 5, initialDelay: .seconds(1), jitter: .none),
            sleep: sleeper.sleep
        )
        var attempts: [Int] = []
        let value = try await retrier.run { attempt in
            attempts.append(attempt)
            if attempt < 3 { throw URLError(.timedOut) }
            return "feed"
        }
        #expect(value == "feed")
        #expect(attempts == [1, 2, 3])
        #expect(sleeper.waits == [.seconds(1), .seconds(2)])
    }

    @Test("stops after maxAttempts and rethrows the last error")
    func exhaustsAttempts() async {
        let sleeper = SleepRecorder()
        let retrier = Retrier(policy: RetryPolicy(maxAttempts: 3, jitter: .none), sleep: sleeper.sleep)
        var calls = 0
        await #expect(throws: HTTPStatusError(statusCode: 503)) {
            try await retrier.run { _ in
                calls += 1
                throw HTTPStatusError(statusCode: 503)
            }
        }
        #expect(calls == 3)
        #expect(sleeper.waits.count == 2)
    }

    @Test("does not retry a permanent error")
    func permanentError() async {
        let sleeper = SleepRecorder()
        let retrier = Retrier(sleep: sleeper.sleep)
        var calls = 0
        await #expect(throws: HTTPStatusError(statusCode: 404)) {
            try await retrier.run { _ in
                calls += 1
                throw HTTPStatusError(statusCode: 404)
            }
        }
        #expect(calls == 1)
        #expect(sleeper.waits.isEmpty)
    }

    @Test("honours Retry-After, and gives up when it is above maxDelay")
    func retryAfter() async throws {
        let sleeper = SleepRecorder()
        let retrier = Retrier(policy: RetryPolicy(maxAttempts: 3, maxDelay: .seconds(10)), sleep: sleeper.sleep)
        var calls = 0
        _ = try await retrier.run { attempt -> Int in
            calls += 1
            if attempt == 1 { throw HTTPStatusError(statusCode: 429, retryAfter: .seconds(7)) }
            return attempt
        }
        #expect(sleeper.waits == [.seconds(7)])

        calls = 0
        await #expect(throws: HTTPStatusError.self) {
            try await retrier.run { _ in
                calls += 1
                throw HTTPStatusError(statusCode: 503, retryAfter: .seconds(11))
            }
        }
        #expect(calls == 1)
    }

    @Test("stops when the task is cancelled")
    func cancellation() async {
        let retrier = Retrier(policy: RetryPolicy(maxAttempts: 50, initialDelay: .seconds(60)))
        let calls = Counter()
        let task = Task {
            try await retrier.run { _ in
                calls.increment()
                throw URLError(.timedOut)
            }
        }
        while calls.value == 0 { await Task.yield() }
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(calls.value == 1)
    }

    @Test("uses a custom classifier")
    func customClassifier() async throws {
        struct Flaky: Error {}
        let retrier = Retrier(policy: RetryPolicy(maxAttempts: 2), sleep: SleepRecorder().sleep)
        let value = try await retrier.run(classify: { $0 is Flaky ? .retry : .doNotRetry }) { attempt in
            if attempt == 1 { throw Flaky() }
            return attempt
        }
        #expect(value == 2)
    }
}

final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var value: Int { lock.withLock { count } }
    func increment() { lock.withLock { count += 1 } }
}
