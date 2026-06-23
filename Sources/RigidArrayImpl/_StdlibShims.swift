//===----------------------------------------------------------------------===//
//
// Shims for standard library internal helpers that the vendored `RigidArray`
// implementation relies on, but which are not exposed outside of the standard
// library itself (and may not be present in the shipping SDK yet).
//
// Every declaration below is copied verbatim from swiftlang/swift on the
// `release/6.4.x` branch, adapting only standard-library-internal references
// the same way the downloader adapts the vendored sources:
//
//     _precondition                 -> precondition
//     _internalInvariant            -> assert
//     _debugPrecondition            -> assert
//     ._unsafelyUnwrappedUnchecked  -> .unsafelyUnwrapped
//
// and mapping the `SwiftStdlib` / `SwiftCompatibilitySpan` availability domains
// onto this package's availability macro.
//
// Sources:
//     stdlib/public/core/Span/Span.swift
//     stdlib/public/core/Span/OutputSpan.swift
//     stdlib/public/core/UnsafeBufferPointer.swift.gyb
//     stdlib/public/core/Stride.swift
//
//===----------------------------------------------------------------------===//

// MARK: - Span

// Only needed by the `Equatable` / `Hashable` conformances, which require the
// 6.4 standard library to allow `~Copyable` on those protocols.
#if compiler(>=6.4)

@available(SwiftStdlib 5.1, *)
extension Span where Element: Equatable & ~Copyable {
    @_alwaysEmitIntoClient
    public func _elementsEqual(to other: borrowing Self) -> Bool {
        return self.withUnsafeBufferPointer { a in
            other.withUnsafeBufferPointer { b in
                guard a.count == b.count else { return false }
                guard unsafe a.baseAddress != b.baseAddress else { return true }
                var i = 0
                while i < self.count {
                    guard unsafe a[i] == b[i] else { return false }
                    i &+= 1
                }
                return true
            }
        }
    }
}

@available(SwiftStdlib 5.1, *)
extension Span where Element: Hashable & ~Copyable {
    @_alwaysEmitIntoClient
    public func _hashContents(into hasher: inout Hasher) {
        // Note: no discriminating combine call -- caller is expected to do that
        // separately when needed.
        var i = 0
        while i < self.count {
            hasher.combine(unsafe self[unchecked: i])
            i &+= 1
        }
    }
}

#endif

// MARK: - OutputSpan

@available(SwiftStdlib 5.1, *)
extension OutputSpan where Element: ~Copyable {
    @_alwaysEmitIntoClient
    @_lifetime(self: copy self)
    public mutating func _append(
        moving source: UnsafeMutableBufferPointer<Element>
    ) {
        guard source.count > 0 else { return }
        unsafe self.withUnsafeMutableBufferPointer { dst, dstCount in
            let dstEnd = dstCount + source.count
            precondition(dstEnd <= dst.count, "OutputSpan capacity overflow")
            unsafe dst
                ._extracting(uncheckedFrom: dstCount, to: dstEnd)
                ._moveInitializeAll(fromContentsOf: source)
            dstCount &+= source.count
        }
    }

    @_alwaysEmitIntoClient
    @_lifetime(self: copy self)
    @_lifetime(source: copy source)
    public mutating func _append(moving source: inout OutputSpan<Element>) {
        unsafe source.withUnsafeMutableBufferPointer { src, srcCount in
            let items = unsafe src._extracting(uncheckedFrom: 0, to: srcCount)
            unsafe self._append(moving: items)
            srcCount = 0
        }
    }
}

@available(SwiftStdlib 5.1, *)
extension OutputSpan where Element: Copyable {
    @_alwaysEmitIntoClient
    @_lifetime(self: copy self)
    public mutating func _append(copying source: UnsafeBufferPointer<Element>) {
        unsafe self.withUnsafeMutableBufferPointer { dst, dstCount in
            let dstEnd = dstCount + source.count
            precondition(dstEnd <= dst.count, "OutputSpan capacity overflow")
            unsafe dst
                ._extracting(uncheckedFrom: dstCount, to: dstEnd)
                ._initializeAll(fromContentsOf: source)
            dstCount &+= source.count
        }
    }

    @_alwaysEmitIntoClient
    @_lifetime(self: copy self)
    public mutating func _append(copying source: Span<Element>) {
        source.withUnsafeBufferPointer { buffer in
            unsafe self._append(copying: buffer)
        }
    }
}

// MARK: - UnsafeMutableBufferPointer

extension UnsafeMutableBufferPointer where Element: ~Copyable {
    @_alwaysEmitIntoClient
    public func _extracting(first maxLength: Int) -> Self {
        precondition(maxLength >= 0, "Cannot have a prefix of negative length")
        let newCount = Swift.min(maxLength, count)
        return unsafe Self(start: baseAddress, count: newCount)
    }

    @_alwaysEmitIntoClient
    public func _extracting(uncheckedFrom start: Int, to end: Int) -> Self {
        guard let base = self.baseAddress else {
            return unsafe Self(start: nil, count: 0)
        }
        return unsafe Self(start: base + start, count: end &- start)
    }

    @_alwaysEmitIntoClient
    public func _moveInitializeAll(fromContentsOf source: Self) {
        let i = unsafe self.moveInitialize(fromContentsOf: source)
        assert(i == self.endIndex)
    }

    @_alwaysEmitIntoClient
    public func _moveInitializePrefix(
        from source: UnsafeMutableBufferPointer<Element>
    ) -> Int {
        if source.isEmpty { return 0 }
        assert(source.count <= self.count)
        unsafe self.baseAddress.unsafelyUnwrapped.moveInitialize(
            from: source.baseAddress.unsafelyUnwrapped,
            count: source.count
        )
        return source.count
    }
}

extension UnsafeMutableBufferPointer where Element: Copyable {
    @_alwaysEmitIntoClient
    public func _initializeAll(
        fromContentsOf source: UnsafeBufferPointer<Element>
    ) {
        let i = unsafe self.initialize(fromContentsOf: source)
        assert(i == self.endIndex)
    }

    @_alwaysEmitIntoClient
    public func _initializePrefix(
        copying source: UnsafeBufferPointer<Element>
    ) -> Int {
        if source.isEmpty { return 0 }
        precondition(source.count <= self.count)
        unsafe self.baseAddress.unsafelyUnwrapped.initialize(
            from: source.baseAddress.unsafelyUnwrapped,
            count: source.count
        )
        return source.count
    }
}

// MARK: - Strideable

extension Strideable {
    @_alwaysEmitIntoClient
    public mutating func _advance(
        by distance: inout Stride, limitedBy limit: Self
    ) {
        if distance >= 0 {
            guard limit >= self else {
                self = self.advanced(by: distance)
                distance = 0
                return
            }
            let d = Swift.min(distance, self.distance(to: limit))
            self = self.advanced(by: d)
            distance -= d
        } else {
            guard limit <= self else {
                self = self.advanced(by: distance)
                distance = 0
                return
            }
            let d = Swift.max(distance, self.distance(to: limit))
            self = self.advanced(by: d)
            distance -= d
        }
    }
}
