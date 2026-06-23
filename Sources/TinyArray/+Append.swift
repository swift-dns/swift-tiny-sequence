public import BasicContainers
public import RigidArrayImpl

@available(SwiftStdlib 5.1, *)
extension TinyArray {
    @inlinable
    public mutating func append(_ element: Element) {
        switch self.takeBase() {
        case .inline(var inline):
            if let element = inline.pushLast(element) {
                let span = inline.span
                var other = UniqueArray<Element>(minimumCapacity: span.count &+ 1)
                other.append(copying: span)
                other.append(element)
                self = .other(other)
            } else {
                self = .inline(inline)
            }
        case .other(var other):
            other.append(element)
            self = .other(other)
        }
    }
}

@available(SwiftStdlib 5.1, *)
extension TinyArray {
    @inlinable
    public mutating func append(copying newElements: some Sequence<Element>) {
        let done: Void? = newElements.withContiguousStorageIfAvailable { buffer in
            self.append(copying: buffer)
        }
        if done != nil { return }
        for element in newElements {
            self.append(element)
        }
    }

    @inlinable
    public mutating func append(copying newElements: UnsafeBufferPointer<Element>) {
        switch self.takeBase() {
        case .inline(var inline):
            if inline.freeCapacity >= newElements.count {
                inline.append(copying: newElements)
                self = .inline(inline)
            } else {
                let span = inline.span
                var other = UniqueArray<Element>(minimumCapacity: span.count &+ newElements.count)
                other.append(copying: span)
                other.append(copying: newElements)
                self = .other(other)
            }
        case .other(var other):
            other.append(copying: newElements)
            self = .other(other)
        }
    }
}

@available(SwiftStdlib 5.1, *)
extension TinyArray {
    @inlinable
    public mutating func append<E: Error>(
        count: Int,
        initializingWith body: (inout OutputSpan<Element>) throws(E) -> Void
    ) throws(E) {
        switch self.takeBase() {
        case .inline(var inline):
            if inline.freeCapacity >= count {
                do {
                    try inline.append(addingCount: count, initializingWith: body)
                } catch {
                    self = .inline(inline)
                    throw error
                }
                self = .inline(inline)
            } else {
                let span = inline.span
                var other = UniqueArray<Element>(minimumCapacity: span.count &+ count)
                other.append(copying: span)
                do {
                    try other.append(addingCount: count, initializingWith: body)
                } catch {
                    self = .other(other)
                    throw error
                }
                self = .other(other)
            }
        case .other(var other):
            do {
                try other.append(addingCount: count, initializingWith: body)
            } catch {
                self = .other(other)
                throw error
            }
            self = .other(other)
        }
    }
}
