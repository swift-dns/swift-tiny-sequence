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
        case inline(InlineElements)
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
    package static func inline(_ elements: consuming InlineElements) -> Self {
        assert(elements.bytesCount <= InlineElements.useableBytesCount)
        assert(elements.reserveCapacity <= Int32.max)
        return Self(
            base: .inline(elements)
        )
    }

    @inlinable
    package static func inline(reserveCapacity: UInt32) -> Self {
        Self.inline(InlineElements(reserveCapacity: reserveCapacity))
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
