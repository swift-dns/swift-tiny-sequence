@available(swiftTinySequenceApplePlatforms 10.15, *)
public struct TinySequence<Element, InlineElements, OtherContainer>:
    ~Copyable
where
    /// BitwiseCopyable requirement can possibly be lifted in the future.
    Element: BitwiseCopyable,
    InlineElements: ~Copyable,
    InlineElements: _InlineElements,
    InlineElements.Element == Element,
    OtherContainer: ~Copyable
{
    @usableFromInline
    package enum Base: ~Copyable {
        /// `reserveCapacity` is UInt32 to avoid inflating the memory layout stride.
        case inline(InlineElements, reserveCapacity: UInt32)
        case other(OtherContainer)
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
    public static func inline(
        _ inlineElements: consuming InlineElements,
        reserveCapacity: Int
    ) -> Self {
        precondition(reserveCapacity >= 0, "reserveCapacity must be non-negative")
        precondition(
            reserveCapacity <= UInt32.max,
            "reserveCapacity must be less than or equal to UInt32.max"
        )
        let reserveCapacity = UInt32(truncatingIfNeeded: reserveCapacity)
        return .inline(inlineElements, reserveCapacity: reserveCapacity)
    }

    @inlinable
    public static func inline(
        _ inlineElements: consuming InlineElements,
        reserveCapacity: UInt32
    ) -> Self {
        precondition(
            reserveCapacity <= Int.max,
            "reserveCapacity must be less than or equal to Int.max"
        )
        precondition(
            reserveCapacity > InlineElements.capacity,
            "reserveCapacity must have enough space for at least 1 element more than the inline elements"
        )
        return Self(
            base: .inline(
                inlineElements,
                reserveCapacity: reserveCapacity
            )
        )
    }

    @inlinable
    public static func inline(
        _ inlineElements: consuming InlineElements,
        uncheckedReserveCapacity reserveCapacity: UInt32
    ) -> Self {
        Self(base: .inline(inlineElements, reserveCapacity: reserveCapacity))
    }

    @inlinable
    public static func other(_ otherContainer: consuming OtherContainer) -> Self {
        Self(base: .other(otherContainer))
    }
}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence.Base: Sendable
where
    Element: Sendable,
    InlineElements: Sendable,
    OtherContainer: Sendable
{}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence: Sendable where Base: Sendable {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence: SendableMetatype {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence.Base: SendableMetatype {}
