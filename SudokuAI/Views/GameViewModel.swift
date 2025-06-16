import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var userState: SudokuUserState
    
    init(puzzleId: String = "1") {
        self.userState = SudokuUserState(puzzleId: puzzleId)
        self.userState.note(5, at: 0)
    }
    
    func userGuess(guess: Int) {
        /*
         isSolved return
         */
        guard let index = userState.selectedCellIndex else { return }
        if userState.isSelectionEditable {
            let isCorrect = userState.guess(guess, at: index)
        }
    }
    
    func boardTap(index: Int) {
        userState.selectedCellIndex = index
    }
}
