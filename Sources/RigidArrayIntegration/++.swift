public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence where OtherContainer: ~Copyable, OtherContainer == RigidArray<Element> {
    @inlinable
    public func withSpan<T, E: Error>(
        operation: (Span<Element>) throws(E) -> T
    ) throws(E) -> T {
        switch self.base {
        case .inline(let inlineElements, _):
            return try inlineElements.withSpan {
                span throws(E) -> T in
                try operation(span)
            }
        case .other(let otherSequence):
            return try operation(otherSequence.span)
        }
    }

    @inlinable
    public mutating func withMutableSpan<T, E: Error>(
        operation: (consuming MutableSpan<Element>) throws(E) -> T
    ) throws(E) -> T {
        switch self.takeBase() {
        case .inline(var inlineElements, let reserveCapacity):
            do {
                let result = try inlineElements.withMutableSpan {
                    mutableSpan throws(E) -> T in
                    try operation(mutableSpan)
                }
                self = .inline(inlineElements, uncheckedReserveCapacity: reserveCapacity)
                return result
            } catch {
                self = .inline(inlineElements, uncheckedReserveCapacity: reserveCapacity)
                throw error
            }
        case .other(var otherSequence):
            do {
                let result = try operation(otherSequence.mutableSpan)
                self = .other(otherSequence)
                return result
            } catch {
                self = .other(otherSequence)
                throw error
            }
        }
    }
}
