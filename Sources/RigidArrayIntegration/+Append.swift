public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence where OtherContainer: ~Copyable, OtherContainer == RigidArray<Element> {
    public mutating func append(
        _ element: Element
    ) {
        switch self.takeBase() {
        case .inline(var inlineElements, let reserveCapacity):
            if inlineElements.append(element) {
                self = .inline(inlineElements, uncheckedReserveCapacity: reserveCapacity)
            } else {
                let capacity = Int(truncatingIfNeeded: reserveCapacity)
                var otherContainer = RigidArray<Element>(capacity: capacity)
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inlineElements.withSpan { span in
                    otherContainer.append(copying: span)
                }
                otherContainer.append(element)
                self = .other(otherContainer)
            }
        case .other(var otherSequence):
            otherSequence.append(element)
            self = .other(otherSequence)
        }
    }
}
