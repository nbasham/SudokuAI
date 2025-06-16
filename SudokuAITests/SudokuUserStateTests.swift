import XCTest
@testable import  SudokuAI

@MainActor
class SudokuUserStateTests: XCTestCase {
    let testPuzzleId = "1"
    
    private func firstEmptyCellIndex(_ userState: SudokuUserState) -> Int? {
        let puzzle = userState.puzzle
        for i in 0..<81 {
            if puzzle.cells[i] <= 9 { return i }
        }
        return nil
    }

    func testInitWithDefaultState() {
        let userState = SudokuUserState(puzzleId: testPuzzleId)
        XCTAssertEqual(userState.puzzleId, testPuzzleId)
        XCTAssertEqual(userState.boardState.count, 81)
        // Check that cells with puzzleValue > 9 are seeded with their value - 9
        let puzzle = userState.puzzle
        for i in 0..<81 {
            let puzzleValue = puzzle.cells[i]
            if puzzleValue > 9 {
                XCTAssertEqual(userState.boardState[i], puzzleValue - 9, "Given cell should be initialized.")
            } else {
                XCTAssertNil(userState.boardState[i], "Empty cell should be nil.")
            }
        }
    }

    func testGuessSetsCell() {
        let userState = SudokuUserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        userState.guess(3, at: emptyIndex)
        XCTAssertEqual(userState.boardState[emptyIndex], 3)
    }

    func testGuessTogglesCell() {
        let userState = SudokuUserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        userState.guess(4, at: emptyIndex)
        XCTAssertEqual(userState.boardState[emptyIndex], 4)
        userState.guess(4, at: emptyIndex)
        XCTAssertNil(userState.boardState[emptyIndex], "Guessing the same number again should clear the cell.")
    }

    func testGuessDoesNotAffectInvalidIndex() {
        let userState = SudokuUserState(puzzleId: testPuzzleId)
        userState.guess(2, at: -1)
        userState.guess(7, at: 81)
        // Should not crash, and no out-of-bounds error. boardState remains at 81 cells
        XCTAssertEqual(userState.boardState.count, 81)
    }

    func testNoteAddsNoteValue() {
        let userState = SudokuUserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        userState.note(3, at: emptyIndex)
        // A note should be a negative value containing bit for 3
        XCTAssertTrue((userState.boardState[emptyIndex] ?? 0) < 0)
    }

    func testNoteTogglesOff() {
        let userState = SudokuUserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        userState.note(2, at: emptyIndex)
        let first = userState.boardState[emptyIndex]
        userState.note(2, at: emptyIndex)
        let second = userState.boardState[emptyIndex]
        XCTAssertNotEqual(first, nil)
        XCTAssertEqual(second, nil, "Second toggle removes the note.")
    }

    func testRestoreFromInitialState() {
        let initialState = SudokuUserState(puzzleId: testPuzzleId)
        let restoredEmptyIndex = firstEmptyCellIndex(initialState) ?? 0
        initialState.selectedCellIndex = 33
        initialState.selectedNumber = 7
        initialState.guess(8, at: restoredEmptyIndex)
        let restored = SudokuUserState(puzzleId: testPuzzleId, initialState: initialState)
        XCTAssertEqual(restored.selectedCellIndex, 33)
        XCTAssertEqual(restored.selectedNumber, 7)
        XCTAssertEqual(restored.boardState, initialState.boardState)
    }
}
