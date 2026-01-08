public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension TinySequence where OtherContainer: ~Copyable, OtherContainer == RigidArray<Element> {
    @inlinable
    public func withSpan<T, E: Error>(
        operation: (Span<Element>) throws(E) -> T
    ) throws(E) -> T {
        switch self.base {
        case .inline(let inlineElements, _, let bytesCount):
            return try inlineElements.withSpan(bytesCount: bytesCount) {
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
        case .inline(var inlineElements, let reserveCapacity, let bytesCount):
            do {
                let result = try inlineElements.withMutableSpan(bytesCount: bytesCount) {
                    mutableSpan throws(E) -> T in
                    try operation(mutableSpan)
                }
                self = .inline(
                    inlineElements,
                    reserveCapacity: reserveCapacity,
                    bytesCount: bytesCount
                )
                return result
            } catch {
                self = .inline(
                    inlineElements,
                    reserveCapacity: reserveCapacity,
                    bytesCount: bytesCount
                )
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
