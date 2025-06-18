import Foundation
import Combine

enum CellAnimationType: Int {
    case none, guess, complete, autoComplete
}

enum CellAttributeType: Int {
    case none, incorrect, initial
}

class GameViewModel: ObservableObject {
    @Published var userState: UserState
    @Published var solved: Bool = false
    @Published var cellAnimations: [CellAnimationType] = Array(repeating: CellAnimationType.none, count: 81)
    @Published var cellAttributes: [CellAttributeType] = Array(repeating: CellAttributeType.none, count: 81)

    init(puzzleId: String = "1") {
        self.userState = UserState(puzzleId: puzzleId)
        for index in 0...80 {
            let puzzleValue = userState.puzzle.cells[index]
            if (puzzleValue > 9) {
                cellAttributes[index] = .initial
            }
        }
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
            cellAttributes[index] = isCorrect ? .none : .incorrect
            cellAnimations[index] = .guess
            
            //  remove other occurences of guess in grid
            let indicies = indicesForGrid(of: index)
            for i in indicies {
                if i != index {
                    if userState.boardState[i] == guess && userState.isCellEditable(i) {
                        _ = userState.guess(guess, at: i)
                    }
                }
            }

            // Check for completed row, col, or grid
            let row = index / 9
            let col = index % 9
            if isRowComplete(row) {
                setAnimationForIndices(indicesForRow(row))
            }
            if isColComplete(col) {
                setAnimationForIndices(indicesForCol(col))
            }
            if isGridComplete(containing: index) {
                setAnimationForIndices(indicesForGrid(of: index))
            }
            if isNumberComplete(guess) {
                setAnimationForIndices(indicesForNumber(guess))
                if userState.selectedNumber == guess {
                    userState.selectedNumber = nil
                }
            }
            
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
        } else {
            if let value = userState.boardState[index] {
                if userState.selectedNumber == value {
                    userState.selectedNumber = nil
                } else {
                    userState.selectedNumber = value
                }
            } else {
            }
        }
    }
    
    private func indicesForRow(_ row: Int) -> [Int] {
        return (0..<9).map { row * 9 + $0 }
    }

    private func indicesForCol(_ col: Int) -> [Int] {
        return (0..<9).map { $0 * 9 + col }
    }

    private func indicesForGrid(of index: Int) -> [Int] {
        let row = index / 9
        let col = index % 9
        let gridRow = (row / 3) * 3
        let gridCol = (col / 3) * 3
        var indices: [Int] = []
        for r in 0..<3 {
            for c in 0..<3 {
                indices.append((gridRow + r) * 9 + (gridCol + c))
            }
        }
        return indices
    }
    
    private func indicesForNumber(_ number: Int) -> [Int] {
        return userState.puzzle.cells.enumerated().compactMap { (idx, cell) in
            let solution = cell > 9 ? cell - 9 : cell
            return solution == number ? idx : nil
        }
    }

    private func isRowComplete(_ row: Int) -> Bool {
        let indices = indicesForRow(row)
        for index in indices {
            let solution = userState.puzzle.cells[index] > 9 ? userState.puzzle.cells[index] - 9 : userState.puzzle.cells[index]
            if userState.boardState[index] != solution {
                return false
            }
        }
        return true
    }

    private func isColComplete(_ col: Int) -> Bool {
        let indices = indicesForCol(col)
        for index in indices {
            let solution = userState.puzzle.cells[index] > 9 ? userState.puzzle.cells[index] - 9 : userState.puzzle.cells[index]
            if userState.boardState[index] != solution {
                return false
            }
        }
        return true
    }

    private func isGridComplete(containing index: Int) -> Bool {
        let indices = indicesForGrid(of: index)
        for idx in indices {
            let solution = userState.puzzle.cells[idx] > 9 ? userState.puzzle.cells[idx] - 9 : userState.puzzle.cells[idx]
            if userState.boardState[idx] != solution {
                return false
            }
        }
        return true
    }
    
    private func isNumberComplete(_ number: Int) -> Bool {
        // Count the number of times `number` appears as the solution in the puzzle
        let indices = userState.puzzle.cells.enumerated().compactMap { (idx, cell) -> Int? in
            let solution = cell > 9 ? cell - 9 : cell
            return solution == number ? idx : nil
        }
        // Check if all those indices are filled by the user with the right number
        for idx in indices {
            if userState.boardState[idx] != number {
                return false
            }
        }
        return !indices.isEmpty
    }

    private func setAnimationForIndices(_ indices: [Int]) {
        for i in indices {
            cellAnimations[i] = .complete
        }
    }
}

