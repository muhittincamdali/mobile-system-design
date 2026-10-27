import Foundation
import Testing
@testable import MobileSystemDesign

struct LikeChange: Codable, Sendable, Hashable {
    let postID: Int
    let liked: Bool
}

/// Records sent entries and fails them as scripted.
final class FakeServer: @unchecked Sendable {
    private let lock = NSLock()
    private var failures: [Int: any Error] = [:] // post id → error to throw once
    private var permanent: Set<Int> = []
    private var received: [LikeChange] = []

    var sent: [LikeChange] { lock.withLock { received } }
    func failOnce(postID: Int, with error: any Error) { lock.withLock { failures[postID] = error } }
    func rejectAlways(postID: Int) { _ = lock.withLock { permanent.insert(postID) } }

    func send(_ entry: OutboxEntry<LikeChange>) throws {
        try lock.withLock {
            if permanent.contains(entry.payload.postID) { throw HTTPStatusError(statusCode: 422) }
            if let error = failures.removeValue(forKey: entry.payload.postID) { throw error }
            received.append(entry.payload)
        }
    }
}

/// A store whose saves can be made to fail.
final class FlakyStore: OutboxStore, @unchecked Sendable {
    private let lock = NSLock()
    private var saved = OutboxSnapshot<LikeChange>()
    var failSaves = false
    var snapshot: OutboxSnapshot<LikeChange> { lock.withLock { saved } }

    func load() throws -> OutboxSnapshot<LikeChange> { lock.withLock { saved } }
    func save(_ snapshot: OutboxSnapshot<LikeChange>) throws {
        try lock.withLock {
            if failSaves { throw CocoaError(.fileWriteOutOfSpace) }
            saved = snapshot
        }
    }
}

@Suite("Outbox")
struct OutboxTests {
    let now = Date(timeIntervalSince1970: 1_800_000_000)
    let server = FakeServer()

    func makeOutbox(
        store: some OutboxStore<LikeChange> = InMemoryOutboxStore<LikeChange>(),
        capacity: Int = 100,
        deadLetterLimit: Int = 10,
        policy: RetryPolicy = RetryPolicy(maxAttempts: 3, initialDelay: .seconds(10), jitter: .none)
    ) throws -> Outbox<LikeChange> {
        try Outbox(store: store, capacity: capacity, deadLetterLimit: deadLetterLimit, retryPolicy: policy)
    }

    @Test("sends entries in the order they were enqueued")
    func sendsInOrder() async throws {
        let outbox = try makeOutbox()
        for id in 1...3 { try await outbox.enqueue(LikeChange(postID: id, liked: true), now: now) }
        let report = await outbox.flush(now: now) { try server.send($0) }
        #expect(server.sent.map(\.postID) == [1, 2, 3])
        #expect(report.delivered.count == 3)
        #expect(report.remaining == 0)
        #expect(await outbox.pending.isEmpty)
    }

    @Test("a temporary failure keeps the entry at the head and schedules a retry")
    func temporaryFailureBlocksQueue() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        try await outbox.enqueue(LikeChange(postID: 2, liked: true), now: now)
        server.failOnce(postID: 1, with: URLError(.networkConnectionLost))

        let first = await outbox.flush(now: now) { try server.send($0) }
        #expect(first.delivered.isEmpty)
        #expect(first.nextAttempt == now.addingTimeInterval(10))
        #expect(server.sent.isEmpty) // entry 2 did not overtake entry 1

        let early = await outbox.flush(now: now.addingTimeInterval(5)) { try server.send($0) }
        #expect(early.delivered.isEmpty)
        #expect(await outbox.pending.first?.attempts == 1)

        let later = await outbox.flush(now: now.addingTimeInterval(10)) { try server.send($0) }
        #expect(later.delivered.count == 2)
        #expect(server.sent.map(\.postID) == [1, 2])
    }

    @Test("a permanent failure moves the entry to the dead letters and continues")
    func permanentFailure() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        try await outbox.enqueue(LikeChange(postID: 2, liked: true), now: now)
        server.rejectAlways(postID: 1)

        let report = await outbox.flush(now: now) { try server.send($0) }
        #expect(report.deadLettered.count == 1)
        #expect(report.delivered.count == 1)
        #expect(await outbox.deadLetters.map(\.payload.postID) == [1])
        #expect(await outbox.deadLetters.first?.attempts == 1)
    }

    @Test("an entry that runs out of attempts becomes a dead letter")
    func attemptsExhausted() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        var time = now
        for _ in 0..<3 {
            server.failOnce(postID: 1, with: URLError(.timedOut))
            let report = await outbox.flush(now: time) { try server.send($0) }
            time = report.nextAttempt ?? time
        }
        #expect(await outbox.pending.isEmpty)
        #expect(await outbox.deadLetters.first?.attempts == 3)
    }

    @Test("Retry-After from the server sets the next attempt")
    func retryAfter() async throws {
        let outbox = try makeOutbox(policy: RetryPolicy(maxAttempts: 3, maxDelay: .seconds(90)))
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        server.failOnce(postID: 1, with: HTTPStatusError(statusCode: 429, retryAfter: .seconds(90)))
        let report = await outbox.flush(now: now) { try server.send($0) }
        #expect(report.nextAttempt == now.addingTimeInterval(90))
    }

    @Test("a Retry-After above the policy's maximum delay moves the entry to the dead letters, as Retrier gives up")
    func retryAfterAboveMaximum() async throws {
        let outbox = try makeOutbox(policy: RetryPolicy(maxAttempts: 3, maxDelay: .seconds(90)))
        for id in 1...2 { try await outbox.enqueue(LikeChange(postID: id, liked: true), now: now) }
        server.failOnce(postID: 1, with: HTTPStatusError(statusCode: 503, retryAfter: .seconds(86_400)))
        let report = await outbox.flush(now: now) { try server.send($0) }
        #expect(report.deadLettered.count == 1)
        #expect(report.nextAttempt == nil)
        #expect(server.sent.map(\.postID) == [2]) // the next change is not held behind it
        #expect(await outbox.deadLetters.map(\.payload.postID) == [1])
    }

    @Test("a coalescing key keeps only the latest change")
    func coalescing() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), coalescingKey: "like-1", now: now)
        try await outbox.enqueue(LikeChange(postID: 2, liked: true), coalescingKey: "like-2", now: now)
        try await outbox.enqueue(LikeChange(postID: 1, liked: false), coalescingKey: "like-1", now: now)
        #expect(await outbox.pending.map(\.payload) == [LikeChange(postID: 2, liked: true), LikeChange(postID: 1, liked: false)])
    }

    @Test("an entry being sent is not replaced, and changes made during a flush wait for the next one")
    func coalescingSkipsInFlight() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), coalescingKey: "like-1", now: now)
        let send: @Sendable (OutboxEntry<LikeChange>) async throws -> Void = { entry in
            // The user taps again while the change is on the wire, every time.
            try await outbox.enqueue(LikeChange(postID: 1, liked: !entry.payload.liked), coalescingKey: "like-1", now: now)
            try server.send(entry)
        }
        let first = await outbox.flush(now: now, send: send)
        #expect(first.delivered.count == 1)
        #expect(first.remaining == 1)
        let second = await outbox.flush(now: now, send: send)
        #expect(second.delivered.count == 1)
        #expect(server.sent == [LikeChange(postID: 1, liked: true), LikeChange(postID: 1, liked: false)])
    }

    @Test("refuses entries beyond the capacity and leaves the queue unchanged")
    func capacity() async throws {
        let outbox = try makeOutbox(capacity: 2)
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), coalescingKey: "like-1", now: now)
        try await outbox.enqueue(LikeChange(postID: 2, liked: true), coalescingKey: "like-2", now: now)
        await #expect(throws: OutboxError.full(capacity: 2)) {
            try await outbox.enqueue(LikeChange(postID: 3, liked: true), now: now)
        }
        #expect(await outbox.pending.count == 2)
        // A coalesced change still fits: it replaces the waiting one.
        try await outbox.enqueue(LikeChange(postID: 1, liked: false), coalescingKey: "like-1", now: now)
        #expect(await outbox.pending.map(\.payload.postID) == [2, 1])
    }

    @Test("loading more entries than the capacity keeps the oldest pending and moves the rest to the dead letters")
    func loadAboveCapacity() async throws {
        let store = InMemoryOutboxStore<LikeChange>()
        let saved = (1...5).map { OutboxEntry(payload: LikeChange(postID: $0, liked: true), coalescingKey: nil, createdAt: now) }
        let rejected = OutboxEntry(payload: LikeChange(postID: 0, liked: true), coalescingKey: nil, createdAt: now)
        try store.save(OutboxSnapshot(pending: saved, deadLetters: [rejected]))

        let outbox = try makeOutbox(store: store, capacity: 2, deadLetterLimit: 3)
        #expect(await outbox.pending.map(\.payload.postID) == [1, 2])
        #expect(await outbox.deadLetters.map(\.payload.postID) == [3, 4, 5])
        await #expect(throws: OutboxError.full(capacity: 2)) {
            try await outbox.enqueue(LikeChange(postID: 6, liked: true), now: now)
        }
    }

    @Test("the dead letters keep only the newest entries")
    func deadLetterLimit() async throws {
        let outbox = try makeOutbox(deadLetterLimit: 2)
        for id in 1...4 {
            server.rejectAlways(postID: id)
            try await outbox.enqueue(LikeChange(postID: id, liked: true), now: now)
        }
        _ = await outbox.flush(now: now) { try server.send($0) }
        #expect(await outbox.deadLetters.map(\.payload.postID) == [3, 4])
    }

    @Test("a dead letter can be retried")
    func retryDeadLetter() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        server.failOnce(postID: 1, with: HTTPStatusError(statusCode: 400))
        _ = await outbox.flush(now: now) { try server.send($0) }
        let id = try #require(await outbox.deadLetters.first?.id)

        #expect(await outbox.retryDeadLetter(id: id))
        #expect(await outbox.retryDeadLetter(id: UUID()) == false)
        let report = await outbox.flush(now: now) { try server.send($0) }
        #expect(report.delivered == [id]) // same id: the server can deduplicate
        #expect(await outbox.deadLetters.isEmpty)
    }

    @Test("a second flush while one runs does nothing")
    func singleFlush() async throws {
        let outbox = try makeOutbox()
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        let inner = Box<OutboxFlushReport>()
        let report = await outbox.flush(now: now) { entry in
            inner.value = await outbox.flush(now: now) { try server.send($0) }
            try server.send(entry)
        }
        #expect(inner.value?.skipped == true)
        #expect(report.delivered.count == 1)
        #expect(server.sent.count == 1)
    }

    @Test("every change is saved, and a new outbox continues from the store")
    func persistence() async throws {
        let store = FlakyStore()
        let outbox = try makeOutbox(store: store)
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        try await outbox.enqueue(LikeChange(postID: 2, liked: true), now: now)
        server.failOnce(postID: 2, with: URLError(.timedOut))
        _ = await outbox.flush(now: now) { try server.send($0) }

        let reopened = try makeOutbox(store: store)
        let pending = await reopened.pending
        #expect(pending.map(\.payload.postID) == [2])
        #expect(pending.first?.attempts == 1)
        #expect(pending.first?.notBefore == now.addingTimeInterval(10))
    }

    @Test("a failed save leaves enqueue without effect and flush reports it")
    func saveFailures() async throws {
        let store = FlakyStore()
        let outbox = try makeOutbox(store: store)
        store.failSaves = true
        await #expect(throws: CocoaError.self) {
            try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        }
        #expect(await outbox.pending.isEmpty)

        store.failSaves = false
        try await outbox.enqueue(LikeChange(postID: 1, liked: true), now: now)
        store.failSaves = true
        let report = await outbox.flush(now: now) { try server.send($0) }
        #expect(report.saveFailed)
        #expect(report.delivered.count == 1)
        #expect(store.snapshot.pending.count == 1) // the store still has the old state
    }
}

final class Box<Value>: @unchecked Sendable {
    var value: Value?
}

@Suite("FileOutboxStore")
struct FileOutboxStoreTests {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("OutboxTests-\(UUID().uuidString)", isDirectory: true)

    @Test("a missing file loads as an empty outbox")
    func missingFile() throws {
        let store = FileOutboxStore<LikeChange>(fileURL: directory.appendingPathComponent("none.json"))
        let snapshot = try store.load()
        #expect(snapshot.pending.isEmpty && snapshot.deadLetters.isEmpty)
    }

    @Test("round-trips entries through the file and creates the folder")
    func roundTrip() async throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("nested/outbox.json")
        let outbox = try Outbox(store: FileOutboxStore<LikeChange>(fileURL: url))
        let entry = try await outbox.enqueue(LikeChange(postID: 7, liked: true), coalescingKey: "like-7")

        let reloaded = try FileOutboxStore<LikeChange>(fileURL: url).load()
        #expect(reloaded.pending == [entry])
    }

    @Test("refuses to read a file above the size limit")
    func sizeLimit() throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("big.json")
        try Data(repeating: 0x20, count: 2_048).write(to: url)
        let store = FileOutboxStore<LikeChange>(fileURL: url, maximumFileSize: 1_024)
        #expect(throws: OutboxError.storeTooLarge) { try store.load() }
        #expect(throws: OutboxError.storeTooLarge) {
            try Outbox(store: store)
        }
    }

    @Test("reads a file exactly at the size limit")
    func exactlyAtLimit() async throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("exact.json")
        let writer = FileOutboxStore<LikeChange>(fileURL: url)
        try writer.save(OutboxSnapshot())
        let size = try Data(contentsOf: url).count
        #expect(try FileOutboxStore<LikeChange>(fileURL: url, maximumFileSize: size).load().pending.isEmpty)
        #expect(throws: OutboxError.storeTooLarge) {
            try FileOutboxStore<LikeChange>(fileURL: url, maximumFileSize: size - 1).load()
        }
        #expect(try FileOutboxStore<LikeChange>(fileURL: url, maximumFileSize: .max).load().pending.isEmpty)
    }

    @Test("refuses to write more than the size limit")
    func writeLimit() throws {
        let store = FileOutboxStore<LikeChange>(fileURL: directory.appendingPathComponent("small.json"), maximumFileSize: 10)
        let snapshot = OutboxSnapshot(pending: [OutboxEntry(payload: LikeChange(postID: 1, liked: true), coalescingKey: nil, createdAt: Date())])
        #expect(throws: OutboxError.storeTooLarge) { try store.save(snapshot) }
    }

    @Test("a corrupted file throws instead of losing the entries silently")
    func corruptedFile() throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("broken.json")
        try Data("{\"pending\": [".utf8).write(to: url)
        #expect(throws: DecodingError.self) { try FileOutboxStore<LikeChange>(fileURL: url).load() }
    }
}
