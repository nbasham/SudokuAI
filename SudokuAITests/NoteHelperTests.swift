import Testing

@Suite("NoteHelper: Sudoku note logic")
struct NoteHelperTests {
    @Test("noteValue(for:) returns correct single bit")
    func testNoteValue() async throws {
        for note in 1...9 {
            let value = NoteHelper.noteValue(for: note)
            #expect(value == 1 << (note - 1))
        }
        #expect(NoteHelper.noteValue(for: 0) == 0)
        #expect(NoteHelper.noteValue(for: 10) == 0)
    }

    @Test("contains(notes:note:) identifies present and absent notes")
    func testContains() async throws {
        var notes = 0
        notes = NoteHelper.adding(notes: notes, note: 4)
        notes = NoteHelper.adding(notes: notes, note: 7)
        #expect(NoteHelper.contains(notes: notes, note: 4))
        #expect(NoteHelper.contains(notes: notes, note: 7))
        #expect(!NoteHelper.contains(notes: notes, note: 3))
        #expect(!NoteHelper.contains(notes: notes, note: 10))
    }

    @Test("adding(notes:note:) sets notes idempotently")
    func testAdding() async throws {
        var notes = 0
        notes = NoteHelper.adding(notes: notes, note: 2)
        notes = NoteHelper.adding(notes: notes, note: 2)
        #expect(NoteHelper.contains(notes: notes, note: 2))
        #expect(notes == NoteHelper.noteValue(for: 2))
    }

    @Test("removing(notes:note:) clears notes idempotently")
    func testRemoving() async throws {
        var notes = NoteHelper.adding(notes: 0, note: 3)
        notes = NoteHelper.removing(notes: notes, note: 3)
        #expect(!NoteHelper.contains(notes: notes, note: 3))
        #expect(notes == 0)
        // Removing again is still zero.
        notes = NoteHelper.removing(notes: notes, note: 3)
        #expect(notes == 0)
    }

    @Test("isEmpty(notes:) detects empty state correctly")
    func testIsEmpty() async throws {
        #expect(NoteHelper.isEmpty(notes: 0))
        let notes = NoteHelper.adding(notes: 0, note: 8)
        #expect(!NoteHelper.isEmpty(notes: notes))
    }
}
