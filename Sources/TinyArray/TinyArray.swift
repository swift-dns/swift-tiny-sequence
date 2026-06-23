public import BasicContainers
public import RigidArrayImpl

@available(SwiftStdlib 5.1, *)
public struct TinyArray<Element>:
    ~Copyable
where
    Element: BitwiseCopyable
{
    @usableFromInline
    package enum Base: ~Copyable {
        case inline(ManagedRigidArray<Element>)
        case other(UniqueArray<Element>)
    }

    @usableFromInline
    package var base: Base

    @inlinable
    package init(base: consuming Base) {
        self.base = base
    }

    @inlinable
    public var isAllocatedInline: Bool {
        switch self.base {
        case .inline: return true
        case .other: return false
        }
    }

    @inlinable
    package consuming func takeBase() -> Base {
        self.base
    }

    @inlinable
    package static func inline(_ elements: consuming ManagedRigidArray<Element>) -> Self {
        Self(base: .inline(elements))
    }

    @inlinable
    public static func other(_ otherContainer: consuming UniqueArray<Element>) -> Self {
        Self(base: .other(otherContainer))
    }

    /// Runs `body` with a `TinyArray` whose inline storage is a stack
    /// allocation of `reserveCapacity` elements.
    ///
    /// The array starts out allocated inline (zero heap allocations). It only
    /// reaches for the heap (by switching to a `UniqueArray`) if it grows past
    /// `reserveCapacity`.
    @inlinable
    public static func withTemporaryInline<E: Error, R: ~Copyable>(
        reserveCapacity: UInt32,
        _ body: (inout Self) throws(E) -> R
    ) throws(E) -> R {
        let byteCount = Int(reserveCapacity) * MemoryLayout<Element>.stride
        return try withUnsafeTemporaryAllocation(
            byteCount: byteCount,
            alignment: MemoryLayout<Element>.alignment
        ) { rawBuffer throws(E) -> R in
            let buffer = rawBuffer.bindMemory(to: Element.self)
            var array = Self.inline(
                ManagedRigidArray<Element>(_storage: buffer, count: 0)
            )
            return try body(&array)
        }
    }
}

@available(SwiftStdlib 5.1, *)
extension TinyArray {
    /// Calls `body` with a `Span` over the array's current elements,
    /// regardless of whether they are stored inline or in the overflow
    /// container.
    @inlinable
    public borrowing func withSpan<R: ~Copyable, E: Error>(
        _ body: (Span<Element>) throws(E) -> R
    ) throws(E) -> R {
        switch self.base {
        case .inline(let array): return try body(array.span)
        case .other(let array): return try body(array.span)
        }
    }
}

@available(SwiftStdlib 5.1, *)
extension TinyArray.Base: Sendable
where
    Element: Sendable
{}

@available(SwiftStdlib 5.1, *)
extension TinyArray: Sendable where Base: Sendable {}

@available(SwiftStdlib 5.1, *)
extension TinyArray: SendableMetatype {}

@available(SwiftStdlib 5.1, *)
extension TinyArray.Base: SendableMetatype {}
