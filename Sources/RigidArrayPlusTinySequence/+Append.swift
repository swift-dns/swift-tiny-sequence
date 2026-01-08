public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinyRigidArray where OtherContainer: ~Copyable, OtherContainer == RigidArray<Element> {
    public mutating func append(_ element: Element) {
        switch self.takeBase() {
        case .inline(var inlineElements, let reserveCapacity, var bytesCount):
            if inlineElements.append(element, bytesCount: &bytesCount) {
                self = .inline(
                    inlineElements,
                    reserveCapacity: reserveCapacity,
                    bytesCount: bytesCount
                )
            } else {
                let capacity = Int(truncatingIfNeeded: reserveCapacity)
                var otherContainer = RigidArray<Element>(capacity: capacity)
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inlineElements.withSpan(bytesCount: bytesCount) { span in
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

    public mutating func append(copying newElements: UnsafeBufferPointer<Element>) {
        switch self.takeBase() {
        case .inline(var inlineElements, let reserveCapacity, var bytesCount):
            if inlineElements.append(copying: newElements, bytesCount: &bytesCount) {
                self = .inline(
                    inlineElements,
                    reserveCapacity: reserveCapacity,
                    bytesCount: bytesCount
                )
            } else {
                let capacity = Int(truncatingIfNeeded: reserveCapacity)
                var otherContainer = RigidArray<Element>(capacity: capacity)
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inlineElements.withSpan(bytesCount: bytesCount) { span in
                    otherContainer.append(copying: span)
                }
                otherContainer.append(copying: newElements)
                self = .other(otherContainer)
            }
        case .other(var otherSequence):
            otherSequence.append(copying: newElements)
            self = .other(otherSequence)
        }
    }

    public mutating func append(contentsOf newElements: some Sequence<Element>) {
        switch self.takeBase() {
        case .inline(var inlineElements, let reserveCapacity, var bytesCount):
            if inlineElements.append(contentsOf: newElements, bytesCount: &bytesCount) {
                self = .inline(
                    inlineElements,
                    reserveCapacity: reserveCapacity,
                    bytesCount: bytesCount
                )
            } else {
                let capacity = Int(truncatingIfNeeded: reserveCapacity)
                var otherContainer = RigidArray<Element>(capacity: capacity)
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inlineElements.withSpan(bytesCount: bytesCount) { span in
                    otherContainer.append(copying: span)
                }
                otherContainer.append(copying: newElements)
                self = .other(otherContainer)
            }
        case .other(var otherSequence):
            otherSequence.append(copying: newElements)
            self = .other(otherSequence)
        }
    }
}
