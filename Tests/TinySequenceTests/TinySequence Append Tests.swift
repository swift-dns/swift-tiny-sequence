import BasicContainers
import Testing
import TinySequence

@Suite
struct `TinySequence Append Tests` {

    @Test func `memory layout stride is expected`() {
        #expect(MemoryLayout<TinyRigidArray24<UInt8>>.stride == 32)
    }
}

// MARK: - `append(_:)` Tests
extension `TinySequence Append Tests` {
    @Test func `append(_:) in TinyRigidArray24<UInt8> works`() {
        var seq: TinyRigidArray24<UInt8> = .inline(
            reserveCapacity: 26
        )

        seq.append(1)
        seq.append(2)
        seq.append(3)
        #expect(Array(copying: seq) == (1...3).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(4)
        seq.append(5)
        seq.append(6)
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(7)
        seq.append(8)
        seq.append(9)
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(10)
        seq.append(11)
        #expect(Array(copying: seq) == (1...11).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(12)
        seq.append(13)
        seq.append(14)
        #expect(Array(copying: seq) == (1...14).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(15)
        seq.append(16)
        seq.append(17)
        #expect(Array(copying: seq) == (1...17).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(18)
        seq.append(19)
        seq.append(20)
        #expect(Array(copying: seq) == (1...20).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(21)
        seq.append(22)
        seq.append(23)
        seq.append(24)
        #expect(Array(copying: seq) == (1...24).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(25)
        seq.append(26)
        #expect(Array(copying: seq) == (1...26).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test func `append(_:) in TinyRigidArray24<UInt16> works`() {
        var seq: TinyRigidArray24<UInt16> = .inline(
            reserveCapacity: 14
        )

        seq.append(1)
        seq.append(2)
        seq.append(3)
        #expect(Array(copying: seq) == (1...3).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(4)
        seq.append(5)
        seq.append(6)
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(7)
        seq.append(8)
        seq.append(9)
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(10)
        seq.append(11)
        #expect(Array(copying: seq) == (1...11).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(12)
        seq.append(13)
        seq.append(14)
        #expect(Array(copying: seq) == (1...14).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test(.enabled(if: MemoryLayout<Int>.size == 8))
    func `append(_:) in TinyRigidArray24<Int> works`() {
        var seq: TinyRigidArray24<Int> = .inline(
            reserveCapacity: 9
        )

        seq.append(1)
        seq.append(2)
        #expect(Array(copying: seq) == (1...2).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(3)
        seq.append(4)
        seq.append(5)
        seq.append(6)
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)

        seq.append(7)
        seq.append(8)
        seq.append(9)
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }
}

// MARK: - `append(contentsOf:)` Tests
extension `TinySequence Append Tests` {
    @Test func `append(contentsOf:) in TinyRigidArray24<UInt8> works`() {
        var seq: TinyRigidArray24<UInt8> = .inline(
            reserveCapacity: 26
        )

        seq.append(contentsOf: [1, 2, 3])
        #expect(Array(copying: seq) == (1...3).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [4, 5, 6])
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [7, 8, 9])
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [10, 11])
        #expect(Array(copying: seq) == (1...11).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [12, 13, 14])
        #expect(Array(copying: seq) == (1...14).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [15, 16, 17])
        #expect(Array(copying: seq) == (1...17).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [18, 19, 20])
        #expect(Array(copying: seq) == (1...20).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [21, 22, 23, 24])
        #expect(Array(copying: seq) == (1...24).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [25, 26])
        #expect(Array(copying: seq) == (1...26).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test func `append(contentsOf:) in TinyRigidArray24<UInt16> works`() {
        var seq: TinyRigidArray24<UInt16> = .inline(
            reserveCapacity: 14
        )

        seq.append(contentsOf: [1, 2, 3])
        #expect(Array(copying: seq) == (1...3).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [4, 5, 6])
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [7, 8, 9])
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [10, 11])
        #expect(Array(copying: seq) == (1...11).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [12, 13, 14])
        #expect(Array(copying: seq) == (1...14).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test(.enabled(if: MemoryLayout<Int>.size == 8))
    func `append(contentsOf:) in TinyRigidArray24<Int> works`() {
        var seq: TinyRigidArray24<Int> = .inline(
            reserveCapacity: 9
        )

        seq.append(contentsOf: [1, 2])
        #expect(Array(copying: seq) == (1...2).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(contentsOf: [3, 4, 5, 6])
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)

        seq.append(contentsOf: [7, 8, 9])
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }
}

// MARK: - `append(count: initializingWith:)` Tests
extension `TinySequence Append Tests` {
    @Test func `append(count:initializingWith:) in TinyRigidArray24<UInt8> works`() {
        var seq: TinyRigidArray24<UInt8> = .inline(
            reserveCapacity: 26
        )

        seq.append(count: 3) { output in
            output.append(1)
            output.append(2)
            output.append(3)
        }
        #expect(Array(copying: seq) == (1...3).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(4)
            output.append(5)
            output.append(6)
        }
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(7)
            output.append(8)
            output.append(9)
        }
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 2) { output in
            output.append(10)
            output.append(11)
        }
        #expect(Array(copying: seq) == (1...11).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(12)
            output.append(13)
            output.append(14)
        }
        #expect(Array(copying: seq) == (1...14).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(15)
            output.append(16)
            output.append(17)
        }
        #expect(Array(copying: seq) == (1...17).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(18)
            output.append(19)
            output.append(20)
        }
        #expect(Array(copying: seq) == (1...20).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 4) { output in
            output.append(21)
            output.append(22)
            output.append(23)
            output.append(24)
        }
        #expect(Array(copying: seq) == (1...24).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 2) { output in
            output.append(25)
            output.append(26)
        }
        #expect(Array(copying: seq) == (1...26).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test func `append(count:initializingWith:) in TinyRigidArray24<UInt16> works`() {
        var seq: TinyRigidArray24<UInt16> = .inline(
            reserveCapacity: 14
        )

        seq.append(count: 3) { output in
            output.append(1)
            output.append(2)
            output.append(3)
        }
        #expect(Array(copying: seq) == (1...3).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(4)
            output.append(5)
            output.append(6)
        }
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(7)
            output.append(8)
            output.append(9)
        }
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 2) { output in
            output.append(10)
            output.append(11)
        }
        #expect(Array(copying: seq) == (1...11).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(12)
            output.append(13)
            output.append(14)
        }
        #expect(Array(copying: seq) == (1...14).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test(.enabled(if: MemoryLayout<Int>.size == 8))
    func `append(count:initializingWith:) in TinyRigidArray24<Int> works`() {
        var seq: TinyRigidArray24<Int> = .inline(
            reserveCapacity: 9
        )

        seq.append(count: 2) { output in
            output.append(1)
            output.append(2)
        }
        #expect(Array(copying: seq) == (1...2).map({ $0 }))
        var isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(count: 4) { output in
            output.append(3)
            output.append(4)
            output.append(5)
            output.append(6)
        }
        #expect(Array(copying: seq) == (1...6).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)

        seq.append(count: 3) { output in
            output.append(7)
            output.append(8)
            output.append(9)
        }
        #expect(Array(copying: seq) == (1...9).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }
}
