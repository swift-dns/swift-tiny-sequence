@available(swiftTinySequenceApplePlatforms 10.15, *)
public protocol _InlineElements<Element>: ~Copyable {
    associatedtype Element: BitwiseCopyable
    associatedtype BitPattern: BitwiseCopyable

    var _bits: BitPattern { get set }

    init()

    mutating func append(_ element: Element, bytesCount: inout UInt8) -> Bool
    mutating func append(
        copying newElements: UnsafeBufferPointer<Element>,
        bytesCount: inout UInt8
    ) -> Bool
    mutating func append(
        contentsOf newElements: some Sequence<Element>,
        bytesCount: inout UInt8
    ) -> Bool
}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension _InlineElements where Self: ~Copyable {
    @inlinable
    static var useableBytesCount: Int {
        MemoryLayout<BitPattern>.size
    }

    @inlinable
    static var capacity: Int {
        Self.useableBytesCount / MemoryLayout<Element>.stride
    }

    @inlinable
    func freeCapacity(bytesCount: UInt8) -> Int {
        (Self.useableBytesCount &- Int(bytesCount)) / MemoryLayout<Element>.stride
    }

    // public var span: Span<Element> {
    //     @_lifetime(borrow self)
    //     get {
    //         // God forgive me for escaping this pointer out of the closure 🤲🏻
    //         let ptrBytes = withUnsafeBytes(of: self._bits) { ptr in
    //             let bytesCount = ptr[Self.bytesCountByteIndex]
    //             let bytesCount = Int(bytesCount) &* MemoryLayout<Element>.stride
    //             assert(bytesCount < ptr.bytesCount)
    //             let range = Range(uncheckedBounds: (0, bytesCount))
    //             print("ptr range", Array(ptr[range]))
    //             return ptr[range]
    //         }
    //         let bytes = Span<Element>(_unsafeBytes: ptrBytes)
    //         print("bytes", Array(copying: bytes))
    //         return _overrideLifetime(bytes, borrowing: self)
    //     }
    // }

    // public var mutableSpan: MutableSpan<Element> {
    //     @_lifetime(&self)
    //     mutating get {
    //         // God forgive me for escaping this pointer out of the closure 🤲🏻
    //         let ptrBytes = withUnsafeMutableBytes(of: &self._bits) { ptr in
    //             let bytesCount = ptr[Self.bytesCountByteIndex]
    //             let bytesCount = Int(bytesCount) &* MemoryLayout<Element>.stride
    //             assert(bytesCount < ptr.bytesCount)
    //             let range = Range(uncheckedBounds: (0, bytesCount))
    //             return ptr[range]
    //         }
    //         let bytes = MutableSpan<Element>(_unsafeBytes: ptrBytes)
    //         return _overrideLifetime(bytes, borrowing: self)
    //     }
    // }

    @inlinable
    package func withSpan<T, E: Error>(
        bytesCount: UInt8,
        operation: (Span<Element>) throws(E) -> T
    ) throws(E) -> T {
        do {
            return try withUnsafeBytes(of: self._bits) { ptr in
                assert(bytesCount <= ptr.count)
                let range = Range(uncheckedBounds: (0, Int(bytesCount)))
                let bytes = ptr[range]
                let span = Span<Element>(_unsafeBytes: bytes)
                return try operation(span)
            }
        } catch let error as E {
            throw error
        } catch {
            fatalError("Impossible code path")
        }
    }

    @inlinable
    package mutating func withMutableSpan<T, E: Error>(
        bytesCount: UInt8,
        operation: (consuming MutableSpan<Element>) throws(E) -> T
    ) throws(E) -> T {
        do {
            return try withUnsafeMutableBytes(of: &self._bits) { ptr in
                assert(bytesCount <= ptr.count)
                let range = Range(uncheckedBounds: (0, Int(bytesCount)))
                let bytes = ptr[range]
                let mutableSpan = MutableSpan<Element>(_unsafeBytes: bytes)
                return try operation(mutableSpan)
            }
        } catch let error as E {
            throw error
        } catch {
            fatalError("Impossible code path")
        }
    }
}
