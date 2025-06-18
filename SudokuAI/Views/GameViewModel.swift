import Foundation
import Combine

enum CellAnimationType: Int {
    case none, guess, grid, row, col, autoComplete
}

class GameViewModel: ObservableObject {
    @Published var userState: UserState
    @Published var solved: Bool = false
    @Published var cellAnimations: [CellAnimationType] = Array(repeating: CellAnimationType.none, count: 81)

    init(puzzleId: String = "3") {
        self.userState = UserState(puzzleId: puzzleId)
//        self.userState.note(5, at: 0)
    }
    
    func setNote(_ note: Int) {
        guard let index = userState.selectedCellIndex else { return }
        userState.note(note, at: index)
    }

    func userGuess(guess: Int) {
        guard !solved else { return }
        guard let index = userState.selectedCellIndex else { return }
        if userState.isSelectionEditable {
            let isCorrect = userState.guess(guess, at: index)
            cellAnimations[index] = .guess
            if SystemSettings.showIncorrect && isCorrect {
                
            }
            if isCorrect && SystemSettings.completeLastNumber {
                if let remainingNumber = userState.onlyRemainingNumber,
                   SystemSettings.completeLastNumber {
                    let indexes = userState.indicesForEmptyCells(solutionIs: remainingNumber)
                    autofill(indexes: indexes, number: remainingNumber) {
                        self.solved = true
                    }
                }
            }
            if userState.isSolved {
                //  Stop timer
                solved = true
            }
        }
    }
    
    /// When only one number remains unsolved, auto fill the remaining value
    private func autofill(indexes: [Int], number: Int, _ completion: @escaping ()->()) {
        userState.selectedNumber = nil
        userState.selectedCellIndex = nil
        var count = 1
        for index in indexes {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Double(count)) { [count = count, index = index] in
//              play touch sound?
                self.cellAnimations[index] = .autoComplete
                _ = self.userState.guess(number, at: index)
                if count == indexes.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        completion()
                    }
                }
            }
            count += 1
        }
    }

    func boardTap(index: Int) {
        if userState.isEditable(index: index) {
            userState.selectedCellIndex = index
            userState.selectedNumber = nil
        } else {
            if let value = userState.boardState[index] {
                if userState.selectedNumber == value {
                    userState.selectedNumber = nil
                } else {
                    userState.selectedNumber = value
                }
            } else {
                userState.selectedNumber = nil
            }
        }
    }
}

