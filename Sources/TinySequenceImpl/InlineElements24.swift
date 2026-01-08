public struct _InlineElements24<Element>
where Element: BitwiseCopyable {
    /// 3x UInt64 == 3x 64 bits == 3x 8 bytes == 24 bytes.
    public typealias BitPattern = (UInt64, UInt64, UInt64)

    public var _bits: BitPattern

    public init() {
        self._bits = (0, 0, 0)
    }
}

extension _InlineElements24: Sendable where Element: Sendable {}
extension _InlineElements24: SendableMetatype where Element: SendableMetatype {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension _InlineElements24: _InlineElements {
    /// Returns true if the element was appended, false if the element was not appended because the inline elements are full.
    @inlinable
    public mutating func append(_ element: Element, bytesCount: inout UInt8) -> Bool {
        guard self.freeCapacity(bytesCount: bytesCount) > 0 else {
            return false
        }
        withUnsafeMutableBytes(of: &self._bits) { ptr in
            ptr.baseAddress.unsafelyUnwrapped.storeBytes(
                of: element,
                toByteOffset: Int(bytesCount),
                as: Element.self
            )
        }
        bytesCount &+= UInt8(MemoryLayout<Element>.stride)
        return true
    }

    @inlinable
    public mutating func append(
        copying newElements: UnsafeBufferPointer<Element>,
        bytesCount: inout UInt8
    ) -> Bool {
        let newElementsCount = newElements.count
        guard newElementsCount > 0 else { return true }
        guard self.freeCapacity(bytesCount: bytesCount) >= newElementsCount else {
            return false
        }
        let newElementsBytesCount = newElementsCount * MemoryLayout<Element>.stride
        withUnsafeMutableBytes(of: &self._bits) { ptr in
            ptr.baseAddress.unsafelyUnwrapped
                .advanced(by: Int(bytesCount))
                .copyMemory(
                    from: newElements.baseAddress.unsafelyUnwrapped,
                    byteCount: newElementsBytesCount
                )
        }
        bytesCount &+= UInt8(newElementsBytesCount)
        return true
    }

    @inlinable
    public mutating func append(
        contentsOf newElements: some Sequence<Element>,
        bytesCount: inout UInt8
    ) -> Bool {
        newElements.withContiguousStorageIfAvailable { buffer in
            self.append(copying: buffer, bytesCount: &bytesCount)
        } ?? self.append_slowPath(contentsOf: newElements, bytesCount: &bytesCount)
    }

    @inlinable
    mutating func append_slowPath(
        contentsOf newElements: some Sequence<Element>,
        bytesCount: inout UInt8
    ) -> Bool {
        let initialBytesCount = bytesCount
        return withUnsafeMutableBytes(of: &self._bits) { ptr in
            for element in newElements {
                bytesCount &+= UInt8(MemoryLayout<Element>.stride)

                if bytesCount > Self.useableBytesCount {
                    bytesCount = initialBytesCount
                    return false
                }

                ptr.baseAddress.unsafelyUnwrapped.storeBytes(
                    of: element,
                    toByteOffset: Int(bytesCount),
                    as: Element.self
                )
            }

            return true
        }
    }
}
