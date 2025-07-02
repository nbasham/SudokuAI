import XCTest
@testable import SudokuDoh

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
    
    func testIsSelectionEditableForNonEditableCell() {
        let state = UserState(puzzleId: testPuzzleId)
        let firstSeededIndex = state.puzzle.cells.firstIndex(where: { $0 > 9 })!
        state.selectedCellIndex = firstSeededIndex
        XCTAssertFalse(state.isSelectionEditable)
    }
    
    func testIsSelectionEditableForEditableCell() {
        let state = UserState(puzzleId: testPuzzleId)
        let emptyIndex = firstEmptyCellIndex(state)!
        state.selectedCellIndex = emptyIndex
        XCTAssertTrue(state.isSelectionEditable)
    }
    
    func testIsSolvedDetectsSolvedAndUnsolved() {
        let state = UserState(puzzleId: testPuzzleId)
        // Board is not solved at start
        XCTAssertFalse(state.isSolved)
        // Fill board with correct answers
        for i in 0..<81 {
            if state.puzzle.cells[i] < 10 {
                _ = state.guess(state.puzzle.cells[i], at: i)
            }
        }
        XCTAssertTrue(state.isSolved)
        // Change one cell to incorrect
        let wrongCell = firstEmptyCellIndex(state) ?? 0
        let wrongValue = 1 + ((state.puzzle.cells[wrongCell] > 9 ? state.puzzle.cells[wrongCell] - 9 : state.puzzle.cells[wrongCell]) % 9)
        _ = state.guess(wrongValue, at: wrongCell)
        XCTAssertFalse(state.isSolved)
    }
    
    func testFirstEditableCellIndexReturnsFirstEmptyCell() {
        let state = UserState(puzzleId: testPuzzleId)
        let expected = state.puzzle.cells.firstIndex { $0 <= 9 }
        XCTAssertEqual(state.firstEditableCellIndex, expected)
    }
    
    func testGuessWithInvalidNumber() {
        let state = UserState(puzzleId: testPuzzleId)
        let index = firstEmptyCellIndex(state) ?? 0
        _ = state.guess(0, at: index)
        XCTAssertNil(state.boardState[index])
        _ = state.guess(10, at: index)
        XCTAssertNil(state.boardState[index])
    }
    
    func testNoteWithInvalidNumber() {
        let state = UserState(puzzleId: testPuzzleId)
        let idx = firstEmptyCellIndex(state) ?? 0
        state.note(0, at: idx)
        XCTAssertNil(state.boardState[idx])
        state.note(10, at: idx)
        XCTAssertNil(state.boardState[idx])
    }
    
    func testCodableRoundTrip() throws {
        let state = UserState(puzzleId: testPuzzleId)
        state.selectedCellIndex = 2
        state.selectedNumber = 4
        _ = state.guess(5, at: 5)
        let encoded = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(UserState.self, from: encoded)
        XCTAssertEqual(state.puzzleId, decoded.puzzleId)
        XCTAssertEqual(state.selectedCellIndex, decoded.selectedCellIndex)
        XCTAssertEqual(state.selectedNumber, decoded.selectedNumber)
        XCTAssertEqual(state.boardState, decoded.boardState)
    }
    
    func testPersistenceRoundTrip() {
        let key = "SudokuUserStateTestKeyPersist"    
        let state = UserState(puzzleId: testPuzzleId)
        state.selectedCellIndex = 10
        state.selectedNumber = 7
        _ = state.guess(3, at: 20)
        state.note(5, at: 21)
        state.save(toKey: key)
        let loaded = UserState.load(fromKey: key)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(state.puzzleId, loaded?.puzzleId)
        XCTAssertEqual(state.selectedCellIndex, loaded?.selectedCellIndex)
        XCTAssertEqual(state.selectedNumber, loaded?.selectedNumber)
        XCTAssertEqual(state.boardState, loaded?.boardState)
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func testRestoreStateAfterMultipleGuessesAndNotes() {
        let initial = UserState(puzzleId: testPuzzleId)
        let idx = firstEmptyCellIndex(initial) ?? 0
        initial.selectedCellIndex = idx
        initial.selectedNumber = 2
        _ = initial.guess(7, at: idx)
        initial.note(4, at: idx + 1)
        let restored = UserState(puzzleId: testPuzzleId, initialState: initial)
        XCTAssertEqual(restored.selectedCellIndex, initial.selectedCellIndex)
        XCTAssertEqual(restored.selectedNumber, initial.selectedNumber)
        XCTAssertEqual(restored.boardState, initial.boardState)
    }
    
    func testIndicesForEmptyCellsWithSolution() {
        let state = UserState(puzzleId: testPuzzleId)
        // Find which number is present at a specific empty cell
        let idx = firstEmptyCellIndex(state) ?? 0
        let solution = state.puzzle.cells[idx] > 9 ? state.puzzle.cells[idx] - 9 : state.puzzle.cells[idx]
        let indices = state.indicesForEmptyCells(solutionIs: solution)
        for i in indices {
            XCTAssertNil(state.boardState[i])
            let sol = state.puzzle.cells[i] > 9 ? state.puzzle.cells[i] - 9 : state.puzzle.cells[i]
            XCTAssertEqual(sol, solution)
        }
    }
}
