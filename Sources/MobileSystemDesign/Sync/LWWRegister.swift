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
/// title.merge(remoteTitle)
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

    /// Keeps whichever of the two copies was written last.
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
