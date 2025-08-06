import XCTest
@testable import  SudokuDoh

@MainActor
class GameViewModelTests: XCTestCase {
    func testInitialization() async throws {
        let viewModel = GameViewModel(puzzleId: "1")
        XCTAssertEqual(viewModel.userState.puzzleId, "1")
        XCTAssertFalse(viewModel.solved)
        XCTAssertEqual(viewModel.userState.boardState.count, 81)
        XCTAssertEqual(viewModel.userState.selectedCellIndex, 0)
    }

    func testSetGuessUpdatesBoardState() async throws {
        let viewModel = GameViewModel(puzzleId: "1")
        let editableIndex = viewModel.userState.firstEditableCellIndex
        viewModel.userState.selectedCellIndex = editableIndex
        let guess = 5
        viewModel.setGuess(guess)
        if let idx = editableIndex {
            XCTAssertEqual(viewModel.userState.boardState[idx], guess)
            // CellAttributes should be .none or .incorrect
            XCTAssertTrue([
                CellAttributeType.none,
                CellAttributeType.incorrect
            ].contains(viewModel.cellAttributes[idx]))
        }
    }

    func testSetNoteUpdatesNoteAttributes() async throws {
        let viewModel = GameViewModel(puzzleId: "1")
        let editableIndex = viewModel.userState.firstEditableCellIndex
        viewModel.userState.selectedCellIndex = editableIndex
        let note = 2
        viewModel.setNote(note)
        if let idx = editableIndex {
            // BoardState should now have a negative value indicating a note
            XCTAssertLessThan(viewModel.userState.boardState[idx] ?? 0, 0)
            // Note attributes for that note should be set (could be .conflicting if puzzle contains it elsewhere)
            XCTAssertNotNil(viewModel.noteAttributes[idx][note-1])
        }
    }

    func testBoardTapUpdatesSelectedCellIndex() async throws {
        let viewModel = GameViewModel(puzzleId: "1")
        let editableIndex = viewModel.userState.firstEditableCellIndex
        XCTAssertNotNil(editableIndex)
        viewModel.boardTap(index: editableIndex!)
        XCTAssertEqual(viewModel.userState.selectedCellIndex, editableIndex)
    }

    func testSolvingBoardSetsSolvedTrue() async throws {
        let viewModel = GameViewModel(puzzleId: "1")
        // Fill all editable cells with the correct answer
        for idx in 0..<81 {
            if viewModel.userState.isCellEditable(idx) {
                let solution = viewModel.userState.puzzle.cells[idx]
                viewModel.userState.selectedCellIndex = idx
                viewModel.setGuess(solution)
            }
        }
        XCTAssertTrue(viewModel.userState.isSolved)
    }
}
