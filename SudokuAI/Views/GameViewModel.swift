import Foundation
import Combine

enum CellAnimationType: Int {
    /// No animation is applied to the cell.
    case none
    /// The cell animates to indicate a guess was entered.
    case guess
    /// The cell animates to show completion of a row, column, grid, or number.
    case complete
    /// The cell animates to indicate it was auto-filled by the system.
    case autoComplete
}

enum CellAttributeType: Int {
    /// Default state, no special attribute is applied to the cell.
    case none
    /// The cell is marked as having an incorrect guess.
    case incorrect
    /// The cell is an initial, given value in the puzzle (not editable).
    case initial
}

enum NoteAttributeType: Int {
    case none, conflicting
}

struct UndoState {
    let selectedCellIndex: Int?
    let selectedNumber: Int?
    let boardState: [Int?]
    init(state: UserState) {
        self.selectedCellIndex = state.selectedCellIndex
        self.selectedNumber = state.selectedNumber
        self.boardState = state.boardState
    }
}

class GameViewModel: ObservableObject {
    @Published var userState: UserState
    @Published var solved: Bool = false
    @Published var cellAnimations: [CellAnimationType] = Array(repeating: CellAnimationType.none, count: 81)
    @Published var cellAttributes: [CellAttributeType] = Array(repeating: CellAttributeType.none, count: 81)
    @Published var noteAttributes: [[NoteAttributeType]] = Array(repeating: Array(repeating: NoteAttributeType.none, count: 9), count: 81)
    var undoManager: UndoHistory<UndoState>
    var lastGuess: Int?
    let timer: GameTimer

    static var rowIndicesCache: [Int: [Int]] = [:]
    static var colIndicesCache: [Int: [Int]] = [:]
    static var gridIndicesCache: [Int: [Int]] = [:]
    
    var puzzleTitle: String {
        let revealedCount = userState.puzzle.cells.filter { $0 > 9 }.count
        if revealedCount >= 36 {
            return "Easy"
        } else if revealedCount >= 33 {
            return "Medium"
        } else if revealedCount >= 30 {
            return "Hard"
        }
        return "Evil"
    }

    init(puzzleId: String) {
        let state = UserState(puzzleId: puzzleId)
        self.userState = state
        self.undoManager = UndoHistory(initialValue: UndoState(state: state))
        self.timer = GameTimer()
    }
    
    func startGame() {
        timer.start { newTime in
            self.userState.elapsed = newTime
        }
    }
    
    func endGame() {
        solved = true
        timer.stop()
    }

    func gameOver() {
        let newPuzzleId = UUID().uuidString
        userState.reset(toPuzzleId: newPuzzleId)
        self.solved = false
        self.cellAnimations = Array(repeating: .none, count: 81)
        self.cellAttributes = Array(repeating: .none, count: 81)
        self.noteAttributes = Array(repeating: Array(repeating: .none, count: 9), count: 81)
        self.undoManager = UndoHistory(initialValue: UndoState(state: userState))
        self.lastGuess = nil
    }
    
    func setNote(_ note: Int) {
        guard let index = userState.selectedCellIndex else { return }
        userState.note(note, at: index)
        lastGuess = -note
        undoManager.currentItem = UndoState(state: userState)
        //  Calculate note attributes
        let row = index / 9
        let col = index % 9
        let rowIndices = indicesForRow(row)
        let colIndices = indicesForCol(col)
        let gridIndices = indicesForGrid(of: index)
        let allAffected = Set(rowIndices + colIndices + gridIndices)
        for i in allAffected {
            if let value = userState.boardState[i] {
                if value == note { //NoteHelper.contains(note, cellValue: value) {
                    noteAttributes[index][note-1] = .conflicting
                }
            }
        }
    }

    func setGuess(_ guess: Int) {
        guard !solved else { return }
        guard let index = userState.selectedCellIndex else { return }
        if userState.isSelectionEditable {
            let isCorrect = userState.guess(guess, at: index)
            lastGuess = guess
            undoManager.currentItem = UndoState(state: userState)
            cellAttributes[index] = isCorrect ? .none : .incorrect
            cellAnimations[index] = .guess
            
            // Remove notes of this number from grid, row, and col
            let row = index / 9
            let col = index % 9
            let rowIndices = indicesForRow(row)
            let colIndices = indicesForCol(col)
            let gridIndices = indicesForGrid(of: index)
            let allAffected = Set(rowIndices + colIndices + gridIndices).subtracting([index])
            for i in allAffected {
                if let value = userState.boardState[i], value < 0 {
                    if NoteHelper.contains(guess, cellValue: value) {
                        userState.note(guess, at: i)
                    }
                }
            }
            
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
                    lastGuess = nil
                }
                if lastGuess == guess {
                    lastGuess = nil
                }
            }
            
            if SystemSettings.showIncorrect && isCorrect {
                
            }
            
            if isCorrect && SystemSettings.completeLastNumber {
                if let remainingNumber = userState.onlyRemainingNumber,
                   SystemSettings.completeLastNumber {
                    let indexes = userState.indicesForEmptyCells(solutionIs: remainingNumber)
                    autofill(indexes: indexes, number: remainingNumber) {
                        self.endGame()
                    }
                }
            }
            if userState.isSolved {
                self.endGame()
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

    func boardDoubleTap(index: Int) {
        if userState.isEditable(index: index), let lastGuess {
            userState.selectedCellIndex = index
            if lastGuess > 0 {
                setGuess(lastGuess)
            } else {
                setNote(-lastGuess)
            }
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
                lastGuess = userState.selectedNumber
            } else {
            }
        }
    }

    private func indicesForRow(_ row: Int) -> [Int] {
        if let cached = GameViewModel.rowIndicesCache[row] {
            return cached
        }
        let indices = (0..<9).map { row * 9 + $0 }
        GameViewModel.rowIndicesCache[row] = indices
        return indices
    }

    private func indicesForCol(_ col: Int) -> [Int] {
        if let cached = GameViewModel.colIndicesCache[col] {
            return cached
        }
        let indices = (0..<9).map { $0 * 9 + col }
        GameViewModel.colIndicesCache[col] = indices
        return indices
    }

    private func indicesForGrid(of index: Int) -> [Int] {
        if let cached = GameViewModel.gridIndicesCache[index] {
            return cached
        }
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
        GameViewModel.gridIndicesCache[index] = indices
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

public struct UndoHistory<A> {
    private let initialValue: A
    private var history: [A] = []
    public var currentItem: A {
        get {
            return history.last ?? initialValue
        }
        set {
            history.append(newValue)
        }
    }
    
    public init(initialValue: A) {
        self.initialValue = initialValue
    }
    
    public mutating func undo() {
        guard !history.isEmpty else { return }
        history.removeLast()
    }
}

