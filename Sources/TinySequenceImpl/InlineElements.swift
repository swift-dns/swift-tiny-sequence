@available(swiftTinySequenceApplePlatforms 10.15, *)
public protocol _InlineElements: ~Copyable {
    associatedtype Element: BitwiseCopyable
    associatedtype BitPattern: BitwiseCopyable

    var _bits: BitPattern { get set }
    static var useableBytesCount: Int { get }

    mutating func append(_ element: Element) -> Bool
}

@available(swiftTinySequenceApplePlatforms 10.15, *)
extension _InlineElements where Self: ~Copyable {
    @inlinable
    static var countByteIndex: Int {
        Self.useableBytesCount
    }

    public var count: Int {
        withUnsafeBytes(of: self._bits) {
            Int($0[Self.countByteIndex])
        }
    }

    public static var capacity: Int {
        Self.useableBytesCount / MemoryLayout<Element>.stride
    }

    // public var span: Span<Element> {
    //     @_lifetime(borrow self)
    //     get {
    //         // God forgive me for escaping this pointer out of the closure 🤲🏻
    //         let ptrBytes = withUnsafeBytes(of: self._bits) { ptr in
    //             let count = ptr[Self.countByteIndex]
    //             let byteCount = Int(count) &* MemoryLayout<Element>.stride
    //             assert(byteCount < ptr.count)
    //             let range = Range(uncheckedBounds: (0, byteCount))
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
    //             let count = ptr[Self.countByteIndex]
    //             let byteCount = Int(count) &* MemoryLayout<Element>.stride
    //             assert(byteCount < ptr.count)
    //             let range = Range(uncheckedBounds: (0, byteCount))
    //             return ptr[range]
    //         }
    //         let bytes = MutableSpan<Element>(_unsafeBytes: ptrBytes)
    //         return _overrideLifetime(bytes, borrowing: self)
    //     }
    // }

    @inlinable
    public func withSpan<T, E: Error>(
        operation: (Span<Element>) throws(E) -> T
    ) throws(E) -> T {
        do {
            return try withUnsafeBytes(of: self._bits) { ptr in
                let count = ptr[Self.countByteIndex]
                let byteCount = Int(count) * MemoryLayout<Element>.stride
                assert(byteCount < ptr.count)
                let range = Range(uncheckedBounds: (0, byteCount))
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
    public mutating func withMutableSpan<T, E: Error>(
        operation: (consuming MutableSpan<Element>) throws(E) -> T
    ) throws(E) -> T {
        do {
            return try withUnsafeMutableBytes(of: &self._bits) { ptr in
                let count = ptr[Self.countByteIndex]
                let byteCount = Int(count) * MemoryLayout<Element>.stride
                assert(byteCount < ptr.count)
                let range = Range(uncheckedBounds: (0, byteCount))
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
