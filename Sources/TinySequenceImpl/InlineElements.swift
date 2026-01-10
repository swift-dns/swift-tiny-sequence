@available(swiftTinySequenceApplePlatforms 10.15, *)
public protocol _InlineElements<Element>: ~Copyable {
    associatedtype Element: BitwiseCopyable
    associatedtype BitPattern: BitwiseCopyable

    var bits: BitPattern { get set }
    var reserveCapacity: UInt32 { get set }
    var bytesCount: UInt8 { get set }
    var span: Span<Element> { @_lifetime(borrow self) borrowing get }
    var mutableSpan: MutableSpan<Element> { @_lifetime(&self) mutating get }

    init(reserveCapacity: UInt32)

    mutating func append(_ element: Element) -> Bool
    mutating func append(copying newElements: UnsafeBufferPointer<Element>) -> Bool
    mutating func append(contentsOf newElements: some Sequence<Element>) -> Bool
    mutating func append<E: Error, Result: ~Copyable>(
        count: Int,
        initializingWith body: (inout OutputSpan<Element>) throws(E) -> Result
    ) throws(E) -> Result?
}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension _InlineElements where Self: ~Copyable {
    /// e.g. if a type takes 5 bytes, we only can make use of 20 bytes and the last 4 will be unusable.
    @inlinable
    static var useableBytesCount: Int {
        Self.capacity &* MemoryLayout<Element>.stride
    }

    @inlinable
    var count: Int {
        Int(self.bytesCount) / MemoryLayout<Element>.stride
    }

    @inlinable
    static var capacityBytesCount: Int {
        MemoryLayout<BitPattern>.size
    }

    @inlinable
    static var capacity: Int {
        MemoryLayout<BitPattern>.size / MemoryLayout<Element>.stride
    }

    @inlinable
    var freeCapacity: Int {
        (Self.capacityBytesCount &- Int(self.bytesCount)) / MemoryLayout<Element>.stride
    }

    @inlinable
    package mutating func withMutableSpan<T, E: Error>(
        body: (consuming MutableSpan<Element>) throws(E) -> T
    ) throws(E) -> T {
        let bytesCount = Int(self.bytesCount)
        return try withUnsafeMutableBytes(of: &self.bits) { ptr throws(E) -> T in
            assert(bytesCount <= ptr.count)
            let range = Range(uncheckedBounds: (0, bytesCount))
            let bytes = ptr[range]
            let mutableSpan = MutableSpan<Element>(_unsafeBytes: bytes)
            return try body(mutableSpan)
        }
    }
}
