import Foundation

/// A change the user made that still has to reach the server.
public struct OutboxEntry<Payload: Codable & Sendable>: Codable, Sendable, Identifiable {
    /// A unique id. Send it as the request's idempotency key, so the server applies the change
    /// once even when a retry repeats a request that had in fact arrived.
    public let id: UUID
    /// The change itself.
    public let payload: Payload
    /// Entries with the same key replace each other while they wait, for example the latest
    /// "liked" state of one post.
    public let coalescingKey: String?
    /// When the entry was enqueued.
    public let createdAt: Date
    /// How many times sending failed.
    public internal(set) var attempts: Int
    /// The entry is not sent before this time; set after a failed attempt.
    public internal(set) var notBefore: Date?

    init(id: UUID = UUID(), payload: Payload, coalescingKey: String?, createdAt: Date) {
        self.id = id
        self.payload = payload
        self.coalescingKey = coalescingKey
        self.createdAt = createdAt
        self.attempts = 0
        self.notBefore = nil
    }
}

extension OutboxEntry: Equatable where Payload: Equatable {}

/// Errors of an ``Outbox`` and its stores.
public enum OutboxError: Error, Sendable, Hashable {
    /// The outbox holds `capacity` entries; nothing more is accepted until some are sent.
    case full(capacity: Int)
    /// The saved file is larger than the store reads.
    case storeTooLarge
}

/// The result of one ``Outbox/flush(now:send:)``.
public struct OutboxFlushReport: Sendable, Hashable {
    /// The ids of the entries the server accepted, in send order.
    public var delivered: [UUID] = []
    /// The ids of the entries moved to the dead letters.
    public var deadLettered: [UUID] = []
    /// Entries still waiting.
    public var remaining = 0
    /// When the next waiting entry may be sent, if a retry was scheduled.
    public var nextAttempt: Date?
    /// `true` when another flush was already running and this one did nothing.
    public var skipped = false
    /// `true` when saving to the store failed; the outbox kept the changes in memory and saves
    /// them again on its next change.
    public var saveFailed = false
}

/// A persistent queue of changes made offline, sent to the server in order once it is
/// reachable: the "outbox" of an offline-first app.
///
/// ```swift
/// let outbox = try Outbox<LikeChange>(store: FileOutboxStore(fileURL: url))
/// try await outbox.enqueue(LikeChange(postID: id, liked: true), coalescingKey: "like-\(id)")
///
/// // When the network is reachable or the app becomes active:
/// let report = await outbox.flush { entry in
///     try await api.send(entry.payload, idempotencyKey: entry.id)
/// }
/// ```
///
/// Entries are sent oldest first, one at a time. A temporary failure keeps the entry at the head
/// and schedules it with the retry policy's backoff, so later changes never overtake earlier
/// ones. A permanent failure, or running out of attempts, moves the entry to
/// ``deadLetters`` for the app to show or discard. Every change is saved to the store before
/// the call returns.
public actor Outbox<Payload: Codable & Sendable> {
    /// Entries waiting to be sent, oldest first.
    public private(set) var pending: [OutboxEntry<Payload>]
    /// Entries the server rejected, that ran out of attempts, or that did not fit in
    /// ``capacity`` when the outbox was loaded, oldest first.
    public private(set) var deadLetters: [OutboxEntry<Payload>]

    /// The most pending entries the outbox accepts.
    public nonisolated let capacity: Int
    /// The most dead letters kept; the oldest are dropped first.
    public nonisolated let deadLetterLimit: Int
    /// Backoff between attempts and the number of attempts before an entry is given up.
    public nonisolated let retryPolicy: RetryPolicy

    private let store: any OutboxStore<Payload>
    private let classify: @Sendable (any Error) -> RetryDecision
    private let random: @Sendable () -> Double
    private var isFlushing = false
    private var sendingID: UUID?

    /// The default policy: up to 10 attempts, from 2 seconds up to 10 minutes apart.
    public static var defaultRetryPolicy: RetryPolicy {
        RetryPolicy(maxAttempts: 10, initialDelay: .seconds(2), multiplier: 2, maxDelay: .seconds(600), jitter: .equal)
    }

    /// Creates an outbox and loads the entries saved in `store`.
    ///
    /// When the store holds more pending entries than `capacity`, for example after an update
    /// lowered it, the oldest `capacity` entries stay pending and the rest move to the end of the
    /// dead letters, where the app can retry or discard them; the store is updated on the next
    /// change.
    ///
    /// - Parameters:
    ///   - store: Where entries are saved.
    ///   - capacity: The most pending entries (at least 1).
    ///   - deadLetterLimit: The most dead letters kept (at least 0).
    ///   - retryPolicy: Backoff and attempt limit.
    ///   - classify: Decides whether a send error is temporary.
    ///   - random: Jitter source, in `0..<1`.
    /// - Throws: The store's load error.
    public init(
        store: some OutboxStore<Payload>,
        capacity: Int = 1_000,
        deadLetterLimit: Int = 100,
        retryPolicy: RetryPolicy = Outbox.defaultRetryPolicy,
        classify: @escaping @Sendable (any Error) -> RetryDecision = RetryDecision.classify,
        random: @escaping @Sendable () -> Double = { Double.random(in: 0..<1) }
    ) throws {
        let snapshot = try store.load()
        self.store = store
        self.capacity = max(1, capacity)
        self.deadLetterLimit = max(0, deadLetterLimit)
        self.retryPolicy = retryPolicy
        self.classify = classify
        self.random = random
        self.pending = Array(snapshot.pending.prefix(self.capacity))
        let overflow = snapshot.pending.dropFirst(self.capacity)
        self.deadLetters = Array((snapshot.deadLetters + overflow).suffix(self.deadLetterLimit))
    }

    /// Adds a change to the end of the queue and saves it.
    ///
    /// With a `coalescingKey`, a waiting entry with the same key is removed first, unless it
    /// is being sent at this moment.
    ///
    /// - Returns: The new entry.
    /// - Throws: ``OutboxError/full(capacity:)`` when the outbox is full, or the store's save
    ///   error. In both cases the outbox is unchanged.
    @discardableResult
    public func enqueue(_ payload: Payload, coalescingKey: String? = nil, now: Date = Date()) throws -> OutboxEntry<Payload> {
        var updated = pending
        if let coalescingKey {
            updated.removeAll { $0.coalescingKey == coalescingKey && $0.id != sendingID }
        }
        guard updated.count < capacity else { throw OutboxError.full(capacity: capacity) }
        let entry = OutboxEntry(payload: payload, coalescingKey: coalescingKey, createdAt: now)
        updated.append(entry)
        try store.save(OutboxSnapshot(pending: updated, deadLetters: deadLetters))
        pending = updated
        return entry
    }

    /// Sends the waiting entries that are due, oldest first.
    ///
    /// It stops at the first entry that is not due yet or fails with a temporary error, and it
    /// sends at most the entries that were waiting when it started. Only one flush runs at a
    /// time; a second call while one runs returns a report with `skipped` set.
    ///
    /// - Parameters:
    ///   - now: The time used to decide which entries are due and to schedule retries.
    ///   - send: Sends one entry. Return normally when the server accepted it; throw otherwise.
    public func flush(
        now: Date = Date(),
        send: @Sendable (OutboxEntry<Payload>) async throws -> Void
    ) async -> OutboxFlushReport {
        var report = OutboxFlushReport()
        guard !isFlushing else {
            report.skipped = true
            report.remaining = pending.count
            return report
        }
        isFlushing = true
        defer { isFlushing = false }

        // Entries enqueued during the flush wait for the next one, so a flush always ends,
        // even when every send makes the app enqueue another change.
        var budget = pending.count
        while budget > 0, let head = pending.first {
            budget -= 1
            if let notBefore = head.notBefore, notBefore > now {
                report.nextAttempt = notBefore
                break
            }
            sendingID = head.id
            do {
                try await send(head)
                sendingID = nil
                pending.removeAll { $0.id == head.id }
                report.delivered.append(head.id)
            } catch {
                sendingID = nil
                if let retryAt = handleFailure(of: head, error: error, now: now) {
                    report.nextAttempt = retryAt
                    report.saveFailed = !save() || report.saveFailed
                    break
                }
                report.deadLettered.append(head.id)
            }
            report.saveFailed = !save() || report.saveFailed
        }
        report.remaining = pending.count
        return report
    }

    /// Moves a dead letter back to the end of the queue with its attempts reset.
    ///
    /// - Returns: `false` when there is no dead letter with that id or the outbox is full.
    @discardableResult
    public func retryDeadLetter(id: UUID) -> Bool {
        guard pending.count < capacity, let index = deadLetters.firstIndex(where: { $0.id == id }) else { return false }
        var entry = deadLetters.remove(at: index)
        entry.attempts = 0
        entry.notBefore = nil
        pending.append(entry)
        save()
        return true
    }

    /// Deletes every dead letter.
    public func discardDeadLetters() {
        deadLetters.removeAll()
        save()
    }

    /// Returns the retry time for a temporary failure, or `nil` after moving the entry to the
    /// dead letters.
    private func handleFailure(of entry: OutboxEntry<Payload>, error: any Error, now: Date) -> Date? {
        guard let index = pending.firstIndex(where: { $0.id == entry.id }) else { return nil }
        var failed = pending[index]
        failed.attempts += 1

        let wait: Duration?
        switch classify(error) {
        case .doNotRetry:
            wait = nil
        case .retry:
            wait = retryPolicy.delay(afterAttempt: failed.attempts, randomUnit: random())
        case .retryAfter(let requested):
            wait = max(requested, .zero)
        }

        guard let wait, failed.attempts < retryPolicy.maxAttempts else {
            pending.remove(at: index)
            deadLetters.append(failed)
            if deadLetters.count > deadLetterLimit {
                deadLetters.removeFirst(deadLetters.count - deadLetterLimit)
            }
            return nil
        }
        let retryAt = now.addingTimeInterval(wait.secondsValue)
        failed.notBefore = retryAt
        pending[index] = failed
        return retryAt
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try store.save(OutboxSnapshot(pending: pending, deadLetters: deadLetters))
            return true
        } catch {
            return false
        }
    }
}
