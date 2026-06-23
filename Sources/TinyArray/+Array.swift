@available(SwiftStdlib 5.1, *)
extension Array where Element: BitwiseCopyable {
    /// Initializes an `Array` by copying the given span.
    @inlinable
    package init(copying span: Span<Element>) {
        self.init(unsafeUninitializedCapacity: span.count) { buffer, initializedCount in
            span.withUnsafeBytes { spanPtr in
                let rawBuffer = UnsafeMutableRawBufferPointer(buffer)
                rawBuffer.copyMemory(from: spanPtr)
            }
            initializedCount = span.count
        }
    }

    /// Initializes an `Array` by copying the elements of the given `TinyArray`.
    @inlinable
    package init(copying array: borrowing TinyArray<Element>) {
        self = array.withSpan { span in
            Array(copying: span)
        }
    }
}
