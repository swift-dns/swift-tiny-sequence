@available(swiftTinySequenceApplePlatforms 10.15, *)
public struct TinySequence<InlineElements, OtherContainer>:
    ~Copyable
where
    InlineElements: ~Copyable,
    InlineElements: _InlineElements,
    /// BitwiseCopyable requirement can possibly be lifted in the future.
    InlineElements.Element: BitwiseCopyable,
    OtherContainer: ~Copyable
{
    public typealias Element = InlineElements.Element

    @usableFromInline
    package enum Base: ~Copyable {
        /// `reserveCapacity` is UInt32 to avoid inflating the memory layout stride.
        case inline(InlineElements, reserveCapacity: UInt32, bytesCount: UInt8)
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
    package static func inline(
        _ inlineElements: consuming InlineElements,
        reserveCapacity: UInt32,
        bytesCount: UInt8
    ) -> Self {
        assert(bytesCount <= InlineElements.useableBytesCount)
        assert(reserveCapacity <= Int32.max)
        return Self(
            base: .inline(
                inlineElements,
                reserveCapacity: reserveCapacity,
                bytesCount: bytesCount
            )
        )
    }

    @inlinable
    package static func inline(reserveCapacity: UInt32) -> Self {
        Self.inline(
            InlineElements(),
            reserveCapacity: reserveCapacity,
            bytesCount: 0
        )
    }

    @inlinable
    public static func other(_ otherContainer: consuming OtherContainer) -> Self {
        Self(base: .other(otherContainer))
    }
}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence.Base: Sendable
where
    InlineElements: Sendable,
    OtherContainer: Sendable
{}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence: Sendable where Base: Sendable {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence: SendableMetatype {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence.Base: SendableMetatype {}
