import Foundation

/// A timestamp from a ``HybridLogicalClock``.
///
/// Timestamps order by wall-clock milliseconds, then by the logical counter, then by node id,
/// so two devices never produce equal timestamps and every device sorts them the same way.
public struct HybridTimestamp: Sendable, Hashable, Codable, Comparable, CustomStringConvertible {
    /// Milliseconds since 1970, as the clock saw them.
    public let milliseconds: Int64
    /// Orders events within the same millisecond.
    public let counter: UInt32
    /// The device or replica that made the timestamp.
    public let node: String

    /// Creates a timestamp.
    public init(milliseconds: Int64, counter: UInt32, node: String) {
        self.milliseconds = milliseconds
        self.counter = counter
        self.node = node
    }

    public static func < (lhs: HybridTimestamp, rhs: HybridTimestamp) -> Bool {
        (lhs.milliseconds, lhs.counter, lhs.node) < (rhs.milliseconds, rhs.counter, rhs.node)
    }

    public var description: String { "\(milliseconds).\(counter)@\(node)" }
}

/// A hybrid logical clock (Kulkarni et al., 2014): timestamps that follow the wall clock but
/// never go backwards and always order an event after the events it has seen.
///
/// Phones have wrong clocks. Last-writer-wins with plain `Date()` lets a phone whose clock is a
/// day ahead win every conflict for a day. A hybrid clock fixes the ordering problem and
/// ``receive(_:physicalTime:)`` rejects timestamps too far in the future.
///
/// ```swift
/// var clock = HybridLogicalClock(node: deviceID)
/// let stamp = try clock.tick()                       // local edit
/// let merged = try clock.receive(serverStamp)        // edit from another device
/// ```
public struct HybridLogicalClock: Sendable, Hashable {
    /// Errors of the clock.
    public enum ClockError: Error, Sendable, Hashable {
        /// A remote timestamp is further ahead of the local wall clock than ``maximumDrift``.
        case driftExceeded(remote: HybridTimestamp, localMilliseconds: Int64)
        /// The wall-clock time is not representable in milliseconds (NaN, infinite or out of
        /// range).
        case invalidPhysicalTime
        /// A remote timestamp's node id is empty or longer than
        /// ``HybridLogicalClock/maximumNodeLength`` UTF-8 bytes.
        case invalidNode
    }

    /// The longest node id ``receive(_:physicalTime:)`` accepts, in UTF-8 bytes. Timestamps are
    /// stored with the values they order, so a remote id of arbitrary length would let another
    /// device grow this device's storage.
    public static let maximumNodeLength = 128

    /// The id of this device or replica.
    public let node: String
    /// How far ahead of the local clock a remote timestamp may be.
    public let maximumDrift: Duration
    /// The latest timestamp this clock produced or received.
    public private(set) var latest: HybridTimestamp

    /// Creates a clock.
    ///
    /// - Parameters:
    ///   - node: A stable id for this device, for example a UUID stored on first launch.
    ///   - maximumDrift: How far ahead a remote timestamp may be (default one minute).
    public init(node: String, maximumDrift: Duration = .seconds(60)) {
        self.node = node
        self.maximumDrift = max(.zero, maximumDrift)
        self.latest = HybridTimestamp(milliseconds: 0, counter: 0, node: node)
    }

    /// Converts a date to whole milliseconds since 1970, or `nil` when the date is NaN,
    /// infinite or outside the `Int64` range. `Int64(_:)` would trap on such values.
    public static func milliseconds(of date: Date) -> Int64? {
        let value = (date.timeIntervalSince1970 * 1000).rounded(.down)
        guard value.isFinite, let milliseconds = Int64(exactly: value) else { return nil }
        return milliseconds
    }

    /// Makes a timestamp for a local event.
    ///
    /// - Parameter physicalTime: The wall-clock time.
    /// - Throws: ``ClockError/invalidPhysicalTime``.
    public mutating func tick(physicalTime: Date = Date()) throws -> HybridTimestamp {
        guard let wall = Self.milliseconds(of: physicalTime) else { throw ClockError.invalidPhysicalTime }
        if wall > latest.milliseconds {
            latest = HybridTimestamp(milliseconds: wall, counter: 0, node: node)
        } else {
            latest = advanced(milliseconds: latest.milliseconds, counter: latest.counter)
        }
        return latest
    }

    /// Merges a timestamp received from another device and makes a timestamp ordered after
    /// both it and every local event.
    ///
    /// - Throws: ``ClockError/driftExceeded(remote:localMilliseconds:)`` when `remote` is more
    ///   than ``maximumDrift`` ahead, ``ClockError/invalidNode`` when its node id is empty or too
    ///   long, ``ClockError/invalidPhysicalTime``. The clock is unchanged when it throws.
    public mutating func receive(_ remote: HybridTimestamp, physicalTime: Date = Date()) throws -> HybridTimestamp {
        guard !remote.node.isEmpty, remote.node.utf8.count <= Self.maximumNodeLength else { throw ClockError.invalidNode }
        guard let wall = Self.milliseconds(of: physicalTime) else { throw ClockError.invalidPhysicalTime }
        let driftMilliseconds = maximumDrift.components.seconds.multipliedReportingOverflow(by: 1000)
        let allowed = driftMilliseconds.overflow ? Int64.max : driftMilliseconds.partialValue
        let (limit, overflow) = wall.addingReportingOverflow(allowed)
        if !overflow, remote.milliseconds > limit {
            throw ClockError.driftExceeded(remote: remote, localMilliseconds: wall)
        }

        let maxWall = max(wall, latest.milliseconds, remote.milliseconds)
        if maxWall == latest.milliseconds, maxWall == remote.milliseconds {
            latest = advanced(milliseconds: maxWall, counter: max(latest.counter, remote.counter))
        } else if maxWall == latest.milliseconds {
            latest = advanced(milliseconds: maxWall, counter: latest.counter)
        } else if maxWall == remote.milliseconds {
            latest = advanced(milliseconds: maxWall, counter: remote.counter)
        } else {
            latest = HybridTimestamp(milliseconds: maxWall, counter: 0, node: node)
        }
        return latest
    }

    /// The timestamp after `(milliseconds, counter)`. When the counter is exhausted it moves to
    /// the next millisecond instead of wrapping around, so timestamps keep increasing.
    private func advanced(milliseconds: Int64, counter: UInt32) -> HybridTimestamp {
        if counter == .max {
            let (next, overflow) = milliseconds.addingReportingOverflow(1)
            return HybridTimestamp(milliseconds: overflow ? milliseconds : next, counter: overflow ? counter : 0, node: node)
        }
        return HybridTimestamp(milliseconds: milliseconds, counter: counter + 1, node: node)
    }
}
