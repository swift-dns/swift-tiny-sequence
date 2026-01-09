public struct _InlineElements24<Element>
where Element: BitwiseCopyable {
    /// 3x UInt64 == 3x 64 bits == 3x 8 bytes == 24 bytes.
    public typealias BitPattern = (UInt64, UInt64, UInt64)

    public var bits: BitPattern
    public var reserveCapacity: UInt32
    public var bytesCount: UInt8

    public init(reserveCapacity: UInt32) {
        self.bits = (0, 0, 0)
        self.reserveCapacity = reserveCapacity
        self.bytesCount = 0
    }
}

extension _InlineElements24: Sendable where Element: Sendable {}
extension _InlineElements24: SendableMetatype where Element: SendableMetatype {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension _InlineElements24: _InlineElements {
    /// Returns true if the element was appended, false if the element was not appended because the inline elements are full.
    @inlinable
    public mutating func append(_ element: Element) -> Bool {
        guard self.freeCapacity > 0 else {
            return false
        }
        withUnsafeMutableBytes(of: &self.bits) { ptr in
            ptr.baseAddress.unsafelyUnwrapped.storeBytes(
                of: element,
                toByteOffset: Int(self.bytesCount),
                as: Element.self
            )
        }
        self.bytesCount &+= UInt8(MemoryLayout<Element>.stride)
        return true
    }

    /// Returns true if the elements were appended, false if the elements were not appended because the inline elements are full.
    @inlinable
    public mutating func append(copying newElements: UnsafeBufferPointer<Element>) -> Bool {
        let newElementsCount = newElements.count
        guard newElementsCount > 0 else { return true }
        guard self.freeCapacity >= newElementsCount else {
            return false
        }
        let newElementsBytesCount = newElementsCount &* MemoryLayout<Element>.stride
        withUnsafeMutableBytes(of: &self.bits) { ptr in
            ptr.baseAddress.unsafelyUnwrapped
                .advanced(by: Int(bytesCount))
                .copyMemory(
                    from: newElements.baseAddress.unsafelyUnwrapped,
                    byteCount: newElementsBytesCount
                )
        }
        self.bytesCount &+= UInt8(newElementsBytesCount)
        return true
    }

    @inlinable
    public mutating func append(contentsOf newElements: some Sequence<Element>) -> Bool {
        newElements.withContiguousStorageIfAvailable { buffer in
            self.append(copying: buffer)
        } ?? self.append_slowPath(contentsOf: newElements)
    }

    @inlinable
    mutating func append_slowPath(contentsOf newElements: some Sequence<Element>) -> Bool {
        let initialBytesCount = self.bytesCount
        return withUnsafeMutableBytes(of: &self.bits) { ptr in
            for element in newElements {
                self.bytesCount &+= UInt8(MemoryLayout<Element>.stride)

                if self.bytesCount > Self.useableBytesCount {
                    self.bytesCount = initialBytesCount
                    return false
                }

                ptr.baseAddress.unsafelyUnwrapped.storeBytes(
                    of: element,
                    toByteOffset: Int(self.bytesCount),
                    as: Element.self
                )
            }

            return true
        }
    }

    /// Append a given number of items to the end of this array by populating
    /// an output span.
    ///
    /// If the array does not have sufficient capacity to hold the requested
    /// number of new elements, then this reallocates the array's storage to
    /// grow its capacity, using a geometric growth rate.
    ///
    /// - Parameters
    ///    - count: The number of items to append to the array.
    ///    - body: A callback that gets called precisely once to directly
    ///       populate newly reserved storage within the array. The function
    ///       is allowed to initialize fewer than `count` items. The array is
    ///       appended however many items the callback adds to the output span
    ///       before it returns (or before it throws an error).
    ///
    /// - Complexity: O(`count`)
    @_alwaysEmitIntoClient
    public mutating func append<E: Error, Result: ~Copyable>(
        count: Int,
        initializingWith body: (inout OutputSpan<Element>) throws(E) -> Result
    ) throws(E) -> Result? {
        if count > self.freeCapacity {
            return nil
        }
        return try withUnsafeMutableBytes(of: &self.bits) { ptr throws(E) -> Result? in
            let bytesCount = Int(self.bytesCount)
            let requiredBytesCount = count &* MemoryLayout<Element>.stride
            let range = Range<Int>(
                uncheckedBounds: (bytesCount, bytesCount &+ requiredBytesCount)
            )
            let buffer = ptr[range].bindMemory(to: Element.self)
            var span = OutputSpan(buffer: buffer, initializedCount: 0)
            defer {
                self.bytesCount &+= UInt8(
                    span.finalize(for: buffer) &* MemoryLayout<Element>.stride
                )
                span = OutputSpan()
            }
            return try body(&span)
        }
    }
}
