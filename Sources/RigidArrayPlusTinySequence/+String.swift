import BasicContainers
import TinySequenceCore
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension String {
    public init<InlineElements: _InlineElements<UInt8>>(
        copying tinySequence: borrowing TinyRigidArray<InlineElements>
    ) {
        self.init(copying: tinySequence.span)
    }
}
