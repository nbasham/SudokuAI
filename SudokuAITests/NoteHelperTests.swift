import XCTest
@testable import  SudokuAI

@MainActor
class NoteHelperTests: XCTestCase {
    func testBitValue() async throws {
        for note in 1...9 {
            let value = Int(pow(2.0, Double(note)))
            XCTAssertEqual(NoteHelper.bitValue(note), value)
        }
    }
    func testAdd() async throws {
        let guessCell: Int? = 1
        let emptyCell: Int? = nil
        let noteCell: Int? = -4
        XCTAssertEqual(NoteHelper.add(1, cellValue: guessCell), -2)
        XCTAssertEqual(NoteHelper.add(1, cellValue: emptyCell), -2)
        XCTAssertEqual(NoteHelper.add(1, cellValue: noteCell), -(NoteHelper.bitValue(2) + NoteHelper.bitValue(1)))
        // Toggle existing value
        XCTAssertEqual(NoteHelper.add(2, cellValue: noteCell), nil)
    }
    func testRemove() async throws {
        let guessCell: Int? = 1
        let emptyCell: Int? = nil
        let noteCell: Int? = -4
        XCTAssertEqual(NoteHelper.remove(1, cellValue: guessCell), guessCell)
        XCTAssertEqual(NoteHelper.remove(1, cellValue: emptyCell), emptyCell)
        // Remove a note that doesn't exist
        XCTAssertEqual(NoteHelper.remove(1, cellValue: noteCell), noteCell)
        XCTAssertEqual(NoteHelper.remove(2, cellValue: noteCell), nil)
    }
    func testContains() async throws {
        let guessCell: Int? = 1
        let emptyCell: Int? = nil
        let noteCell: Int? = -4
        XCTAssertFalse(NoteHelper.contains(1, cellValue: guessCell))
        XCTAssertFalse(NoteHelper.contains(1, cellValue: emptyCell))
        XCTAssertFalse(NoteHelper.contains(1, cellValue: noteCell))
        XCTAssertTrue(NoteHelper.contains(2, cellValue: noteCell))
    }
    func testHasNotes() async throws {
        let guessCell: Int? = 1
        let emptyCell: Int? = nil
        let noteCell: Int? = -4
        XCTAssertFalse(NoteHelper.hasNotes(cellValue: guessCell))
        XCTAssertFalse(NoteHelper.hasNotes(cellValue: emptyCell))
        XCTAssertTrue(NoteHelper.hasNotes(cellValue: noteCell))
    }
}
