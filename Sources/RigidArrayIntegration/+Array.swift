import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension Array {
    public init<InlineElements: _InlineElements>(
        copying tinySequence: borrowing TinyRigidArray<Element, InlineElements>
    ) where Element: BitwiseCopyable {
        self = tinySequence.withSpan { span in
            Self.init(copying: span)
        }
    }
}
