import XCTest
@testable import SudokuAI

@MainActor
class UserStateTests: XCTestCase {
    let testPuzzleId = "1"
    
    private func firstEmptyCellIndex(_ userState: UserState) -> Int? {
        let puzzle = userState.puzzle
        for i in 0..<81 {
            if puzzle.cells[i] <= 9 { return i }
        }
        return nil
    }

    func testInitWithDefaultState() {
        let userState = UserState(puzzleId: testPuzzleId)
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
        let userState = UserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        _ = userState.guess(3, at: emptyIndex)
        XCTAssertEqual(userState.boardState[emptyIndex], 3)
    }

    func testGuessTogglesCell() {
        let userState = UserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        _ = userState.guess(4, at: emptyIndex)
        XCTAssertEqual(userState.boardState[emptyIndex], 4)
        _ = userState.guess(4, at: emptyIndex)
        XCTAssertNil(userState.boardState[emptyIndex], "Guessing the same number again should clear the cell.")
    }

    //  Assumes first cell is 5
    func testGuessIsCorrect() {
        let userState = UserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        var isCorrect = userState.guess(4, at: emptyIndex)
        XCTAssertFalse(isCorrect)
        isCorrect = userState.guess(5, at: emptyIndex)
        XCTAssertTrue(isCorrect)
    }

    func testGuessDoesNotAffectInvalidIndex() {
        let userState = UserState(puzzleId: testPuzzleId)
        _ = userState.guess(2, at: -1)
        _ = userState.guess(7, at: 81)
        // Should not crash, and no out-of-bounds error. boardState remains at 81 cells
        XCTAssertEqual(userState.boardState.count, 81)
    }

    func testNoteAddsNoteValue() {
        let userState = UserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        userState.note(3, at: emptyIndex)
        // A note should be a negative value containing bit for 3
        XCTAssertTrue((userState.boardState[emptyIndex] ?? 0) < 0)
    }

    func testNoteTogglesOff() {
        let userState = UserState(puzzleId: testPuzzleId)
        guard let emptyIndex = firstEmptyCellIndex(userState) else { XCTFail("No empty cell"); return }
        userState.note(2, at: emptyIndex)
        let first = userState.boardState[emptyIndex]
        userState.note(2, at: emptyIndex)
        let second = userState.boardState[emptyIndex]
        XCTAssertNotEqual(first, nil)
        XCTAssertEqual(second, nil, "Second toggle removes the note.")
    }

    func testRestoreFromInitialState() {
        let initialState = UserState(puzzleId: testPuzzleId)
        let restoredEmptyIndex = firstEmptyCellIndex(initialState) ?? 0
        initialState.selectedCellIndex = 33
        initialState.selectedNumber = 7
        _ = initialState.guess(8, at: restoredEmptyIndex)
        let restored = UserState(puzzleId: testPuzzleId, initialState: initialState)
        XCTAssertEqual(restored.selectedCellIndex, 33)
        XCTAssertEqual(restored.selectedNumber, 7)
        XCTAssertEqual(restored.boardState, initialState.boardState)
    }
    
    func testOnlyRemainingNumber() {
        //  Puzzle 3 is almost completed and after answering a 7, has five 8's remaining to be guessed
        let state = UserState(puzzleId: "3")
        var number = state.onlyRemainingNumber
        XCTAssertEqual(number, nil)
        _ = state.guess(7, at: 55)
        number = state.onlyRemainingNumber
        XCTAssertEqual(number, 8)
        let indexes = state.indicesForEmptyCells(solutionIs: 8)
        XCTAssertEqual(indexes.count, 5)
        for index in indexes {
            XCTAssertEqual(state.puzzle.cells[index], 8, "Each empty cell index should now have value 8.")
        }
    }
}
