public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinyRigidArray where OtherContainer: ~Copyable, OtherContainer == RigidArray<Element> {
    public mutating func append(_ element: Element) {
        switch self.takeBase() {
        case .inline(var inlineElements):
            if inlineElements.append(element) {
                self = .inline(inlineElements)
            } else {
                let capacity = Int(truncatingIfNeeded: inlineElements.reserveCapacity)
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
        case .other(var otherContainer):
            otherContainer.append(element)
            self = .other(otherContainer)
        }
    }

    public mutating func append(copying newElements: UnsafeBufferPointer<Element>) {
        switch self.takeBase() {
        case .inline(var inlineElements):
            let reserveCapacity = inlineElements.reserveCapacity
            if inlineElements.append(copying: newElements) {
                self = .inline(inlineElements)
            } else {
                let capacity = Int(truncatingIfNeeded: reserveCapacity)
                var otherContainer = RigidArray<Element>(capacity: capacity)
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inlineElements.withSpan { span in
                    otherContainer.append(copying: span)
                }
                otherContainer.append(copying: newElements)
                self = .other(otherContainer)
            }
        case .other(var otherContainer):
            otherContainer.append(copying: newElements)
            self = .other(otherContainer)
        }
    }

    public mutating func append(contentsOf newElements: some Sequence<Element>) {
        switch self.takeBase() {
        case .inline(var inline):
            if inline.append(contentsOf: newElements) {
                self = .inline(inline)
            } else {
                let capacity = Int(truncatingIfNeeded: inline.reserveCapacity)
                var otherContainer = RigidArray<Element>(capacity: capacity)
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inline.withSpan { span in
                    otherContainer.append(copying: span)
                }
                otherContainer.append(copying: newElements)
                self = .other(otherContainer)
            }
        case .other(var otherContainer):
            otherContainer.append(copying: newElements)
            self = .other(otherContainer)
        }
    }

    public mutating func append<E: Error, Result: ~Copyable>(
        count: Int,
        initializingWith body: (inout OutputSpan<Element>) throws(E) -> Result
    ) throws(E) -> Result? {
        switch self.takeBase() {
        case .inline(var inline):
            do {
                if let result = try inline.append(count: count, initializingWith: body) {
                    self = .inline(inline)
                    return result
                }
            } catch {
                self = .inline(inline)
                throw error
            }

            let capacity = Int(truncatingIfNeeded: inline.reserveCapacity)
            var otherContainer = RigidArray<Element>(capacity: capacity)
            do {
                // otherContainer.edit { output in
                // FIXME: Use this instead of 2 different appends
                // }
                inline.withSpan { span in
                    otherContainer.append(copying: span)
                }
                let result = try otherContainer.append(count: count, initializingWith: body)
                self = .other(otherContainer)
                return result
            } catch {
                self = .other(otherContainer)
                throw error
            }
        case .other(var otherContainer):
            do {
                let result = try otherContainer.append(count: count, initializingWith: body)
                self = .other(otherContainer)
                return result
            } catch {
                self = .other(otherContainer)
                throw error
            }
        }
    }
}
