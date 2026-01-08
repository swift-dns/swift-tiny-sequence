import BasicContainers
import TinySequenceCore
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension Array {
    public init<InlineElements: _InlineElements>(
        copying tinySequence: borrowing TinyRigidArray<InlineElements>
    ) where InlineElements.Element == Self.Element {
        self = tinySequence.withSpan { span in
            Self.init(copying: span)
        }
    }
}
