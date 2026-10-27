import Foundation

/// A value that resolves concurrent edits by keeping the latest one: a last-writer-wins
/// register, the simplest conflict-free replicated data type.
///
/// Each device keeps its own copy and merges copies from others in any order, any number of
/// times; all copies end with the same value. Pair it with ``HybridLogicalClock`` timestamps so
/// "latest" does not depend on whose phone clock is right.
///
/// ```swift
/// var title = LWWRegister("Groceries", timestamp: try clock.tick())
/// try title.merge(remoteTitle, using: &clock)
/// ```
///
/// Last-writer-wins drops the losing edit. That suits a title, a setting or a profile field;
/// for text that two people type into at once, use a sequence CRDT or server-side merge.
public struct LWWRegister<Value: Sendable>: Sendable {
    /// The current value.
    public private(set) var value: Value
    /// The timestamp of the current value.
    public private(set) var timestamp: HybridTimestamp

    /// Creates a register.
    public init(_ value: Value, timestamp: HybridTimestamp) {
        self.value = value
        self.timestamp = timestamp
    }

    /// Sets a new value if `timestamp` is later than the current one.
    ///
    /// - Returns: `true` when the value changed.
    @discardableResult
    public mutating func set(_ newValue: Value, timestamp newTimestamp: HybridTimestamp) -> Bool {
        guard newTimestamp > timestamp else { return false }
        value = newValue
        timestamp = newTimestamp
        return true
    }

    /// Merges a copy received from another device, after `clock` accepted its timestamp.
    ///
    /// The timestamp goes through ``HybridLogicalClock/receive(_:physicalTime:)`` first, so a
    /// copy stamped too far in the future, or with an empty or oversized node id, is rejected
    /// before it can win: a register holding such a timestamp would beat every later local edit.
    /// Receiving also moves `clock` past the remote timestamp, so the next local edit wins over
    /// the merged one.
    ///
    /// - Returns: `true` when this copy took the other one's value.
    /// - Throws: The clock's error. The register and the clock are then unchanged.
    @discardableResult
    public mutating func merge(
        _ other: LWWRegister<Value>,
        using clock: inout HybridLogicalClock,
        physicalTime: Date = Date()
    ) throws -> Bool {
        _ = try clock.receive(other.timestamp, physicalTime: physicalTime)
        return set(other.value, timestamp: other.timestamp)
    }

    /// Keeps whichever of the two copies was written last, without checking the other copy's
    /// timestamp.
    ///
    /// Use it only for copies this device has already checked, such as its own saved state or
    /// replicas merged on a trusted server. For a copy from another device, use
    /// ``merge(_:using:physicalTime:)``.
    ///
    /// - Returns: `true` when this copy took the other one's value.
    @discardableResult
    public mutating func merge(_ other: LWWRegister<Value>) -> Bool {
        set(other.value, timestamp: other.timestamp)
    }
}

extension LWWRegister: Equatable where Value: Equatable {}
extension LWWRegister: Hashable where Value: Hashable {}
extension LWWRegister: Codable where Value: Codable {}
