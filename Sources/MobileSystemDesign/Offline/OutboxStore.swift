import Foundation

/// Where an ``Outbox`` keeps its entries between launches.
public protocol OutboxStore<Payload>: Sendable {
    /// The payload type of the entries.
    associatedtype Payload: Codable & Sendable

    /// Loads the saved entries; an empty array when nothing was saved yet.
    func load() throws -> OutboxSnapshot<Payload>
    /// Replaces the saved entries.
    func save(_ snapshot: OutboxSnapshot<Payload>) throws
}

/// The persisted state of an ``Outbox``.
public struct OutboxSnapshot<Payload: Codable & Sendable>: Codable, Sendable {
    /// Entries waiting to be sent, oldest first.
    public var pending: [OutboxEntry<Payload>]
    /// Entries the server rejected for good, oldest first.
    public var deadLetters: [OutboxEntry<Payload>]

    /// Creates a snapshot.
    public init(pending: [OutboxEntry<Payload>] = [], deadLetters: [OutboxEntry<Payload>] = []) {
        self.pending = pending
        self.deadLetters = deadLetters
    }
}

/// Keeps outbox entries in memory only. Use it in tests and previews.
public final class InMemoryOutboxStore<Payload: Codable & Sendable>: OutboxStore, @unchecked Sendable {
    private let lock = NSLock()
    private var snapshot: OutboxSnapshot<Payload>

    /// Creates a store, optionally with saved entries.
    public init(_ snapshot: OutboxSnapshot<Payload> = OutboxSnapshot()) {
        self.snapshot = snapshot
    }

    public func load() throws -> OutboxSnapshot<Payload> {
        lock.withLock { snapshot }
    }

    public func save(_ snapshot: OutboxSnapshot<Payload>) throws {
        lock.withLock { self.snapshot = snapshot }
    }
}

/// Keeps outbox entries in a JSON file, written atomically.
///
/// Put the file in Application Support, not in Caches: the system may delete caches, and the
/// entries are the user's unsent changes.
public struct FileOutboxStore<Payload: Codable & Sendable>: OutboxStore {
    /// The default limit for the file size: 8 MiB.
    public static var defaultMaximumFileSize: Int { 8 * 1024 * 1024 }

    /// The file's location.
    public let fileURL: URL
    /// The largest file ``load()`` reads. A larger file throws ``OutboxError/storeTooLarge``
    /// instead of being read into memory.
    public let maximumFileSize: Int

    /// Creates a store for the file at `fileURL`. The folder is created when it is missing.
    public init(fileURL: URL, maximumFileSize: Int = Self.defaultMaximumFileSize) {
        self.fileURL = fileURL
        self.maximumFileSize = max(0, maximumFileSize)
    }

    public func load() throws -> OutboxSnapshot<Payload> {
        let handle: FileHandle
        do {
            handle = try FileHandle(forReadingFrom: fileURL)
        } catch CocoaError.fileReadNoSuchFile, CocoaError.fileNoSuchFile {
            return OutboxSnapshot()
        }
        defer { try? handle.close() }
        // Read at most one byte past the limit, so a large file is never read into memory whole,
        // even if it grew after a size check.
        let readLimit = maximumFileSize == .max ? maximumFileSize : maximumFileSize + 1
        let data = try handle.read(upToCount: readLimit) ?? Data()
        guard data.count <= maximumFileSize else { throw OutboxError.storeTooLarge }
        return try JSONDecoder().decode(OutboxSnapshot<Payload>.self, from: data)
    }

    public func save(_ snapshot: OutboxSnapshot<Payload>) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(snapshot)
        guard data.count <= maximumFileSize else { throw OutboxError.storeTooLarge }
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        #if os(iOS)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: fileURL, options: [.atomic])
        #endif
    }
}
