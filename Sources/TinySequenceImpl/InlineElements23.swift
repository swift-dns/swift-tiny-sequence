public struct InlineElements23<Element>
where Element: BitwiseCopyable {
    /// 3x UInt64 == 3x 64 bits == 3x 8 bytes == 24 bytes.
    public typealias BitPattern = (UInt64, UInt64, UInt64)

    public var _bits: BitPattern

    public init() {
        self._bits = (0, 0, 0)
    }

    @inlinable
    public static var useableBytesCount: Int {
        23
    }
}

extension InlineElements23: Sendable where Element: Sendable {}
extension InlineElements23: SendableMetatype where Element: SendableMetatype {}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension InlineElements23: _InlineElements {
    /// Returns true if the element was appended, false if the element was not appended because the inline elements are full.
    @inlinable
    public mutating func append(_ element: Element) -> Bool {
        withUnsafeMutableBytes(of: &self._bits) { ptr in
            let count = ptr[Self.countByteIndex]
            let byteCount = Int(count) &* MemoryLayout<Element>.stride
            assert(byteCount < ptr.count)
            let remainingBytes = Self.useableBytesCount &- byteCount
            let requiredBytes = MemoryLayout<Element>.stride
            if requiredBytes > remainingBytes {
                return false
            }
            ptr.baseAddress.unsafelyUnwrapped.storeBytes(
                of: element,
                toByteOffset: byteCount,
                as: Element.self
            )
            ptr[Self.countByteIndex] = count &+ 1
            return true
        }
    }
}
