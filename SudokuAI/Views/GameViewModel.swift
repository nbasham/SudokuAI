import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var userState: SudokuUserState
    
    init(puzzleId: String = "1") {
        self.userState = SudokuUserState(puzzleId: puzzleId)
        self.userState.note(5, at: 0)
    }
    
    func userGuess(guess: Int) {
        userState.guess(guess, at: 0)
    }
    
    func boardTap(index: Int) {
        userState.selectedCellIndex = index
    }
}
