import BasicContainers
import Testing
import TinySequence

@Suite
struct TinySequenceTests {
    typealias TinyBuffer = TinySequence<
        UInt8,
        InlineElements23<UInt8>,
        RigidArray<UInt8>
    >

    @Test func `memory layout stride is expected`() {
        #expect(MemoryLayout<TinyBuffer>.stride == 32)
    }

    @Test func `appending to TinyRigidArray23<UInt8> works`() {
        var seq: TinyRigidArray23<UInt8> = .inline(
            InlineElements23<UInt8>(),
            reserveCapacity: 25
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
        #expect(Array(copying: seq) == (1...23).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(isAllocatedInline)

        seq.append(24)
        seq.append(25)
        #expect(Array(copying: seq) == (1...25).map({ $0 }))
        isAllocatedInline = seq.isAllocatedInline
        #expect(!isAllocatedInline)
    }

    @Test func `appending to TinyRigidArray23<UInt16> works`() {
        var seq: TinyRigidArray23<UInt16> = .inline(
            InlineElements23<UInt16>(),
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

    @Test func `appending to TinyRigidArray23<Int> works`() {
        var seq: TinyRigidArray23<Int> = .inline(
            InlineElements23<Int>(),
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
