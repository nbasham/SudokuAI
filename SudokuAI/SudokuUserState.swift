import Foundation

class SudokuUserState: Observable {
    let puzzleId: SudokuPuzzle.ID
    var selectedCellIndex: Int? = nil
    var selectedNumber: Int? = nil
    private(set) var boardState: [Int?]
    var puzzle: SudokuPuzzle {
        SudokuPuzzleStore.getPuzze(id: puzzleId)
    }
    
    init(puzzleId: SudokuPuzzle.ID, initialState: SudokuUserState? = nil) {
        self.puzzleId = puzzleId
        if let initialState, initialState.puzzleId == puzzleId {
            self.selectedCellIndex = initialState.selectedCellIndex
            self.selectedNumber = initialState.selectedNumber
            self.boardState = initialState.boardState
        } else {
            self.boardState = Array(repeating: nil, count: 81)
            for index in 0...80 {
                let puzzleValue = puzzle.cells[index]
                if (puzzleValue > 9) {
                    self.boardState[index] = puzzleValue - 9
                }
            }
        }
    }
    
    private func updateCell(_ index: Int, with value: Int?) {
        guard index >= 0 && index < 81 else { return }
        boardState[index] = value
    }
    
    func guess(_ number: Int, at index: Int) {
        if (boardState[index] == number) {
            boardState[index] = nil
        }
        updateCell(index, with: number)
    }
    
//    func note(_ number: Int, at index: Int) {
//        let cellValue = NoteHelper.add(number, at: index)
//        updateCell(index, with: cellValue)
//    }
}
