import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var userState: UserState
    @Published var isPaused: Bool = false
    @Published var solved: Bool = false
    @Published var cellAnimations: [CellAnimationType] = Array(repeating: CellAnimationType.none, count: 81)
    @Published var cellAttributes: [CellAttributeType] = Array(repeating: CellAttributeType.none, count: 81)
    @Published var noteAttributes: [[NoteAttributeType]] = Array(repeating: Array(repeating: NoteAttributeType.none, count: 9), count: 81)
    var undoManager: UndoHistory<UndoState>
    var lastGuess: Int?
    let timer: GameTimer
    var scores: Scores

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
        //  we may need to reload a previously started game
        self.userState = state
        self.undoManager = UndoHistory(initialValue: UndoState(state: state))
        self.timer = GameTimer()
        self.scores = Scores(storage: UserDefaults.standard)
    }
    
    func startGame() {
        self.undoManager = UndoHistory(initialValue: UndoState(state: userState))
        timer.start { newTime in
            self.userState.elapsed = newTime
        }
        userState.selectedNumber = userState.mostCommonNumber()
        lastGuess = userState.selectedNumber
    }
    
    func endGame() {
        solved = true
        let score = Score(id: userState.puzzleId, date: Date(), seconds: Int(userState.elapsed), numIncorrect: 0, level: SystemSettings.level.rawValue, usedColor: false, score: Int(userState.elapsed))
        scores.add(score)
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
        startGame()
    }
    
    func setNote(_ note: Int) {
        guard let index = userState.selectedCellIndex else { return }
        cellAttributes[index] = .none
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
            if isCorrect {
                userState.selectedNumber = guess
            }
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
                    userState.selectedNumber = userState.mostCommonNumber()
                    lastGuess = userState.selectedNumber
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
                    // Using new method to get indices of cells without guesses (nil or notes), not just empty
                    let indexes = userState.indicesForCellsWithoutGuesses(solutionIs: remainingNumber)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // experimenting with leaving a slight delay before auto complete
                        self.autofill(indexes: indexes, number: remainingNumber) {
                            self.endGame()
                        }
                    }
                }
            } else if userState.isSolved {
                self.endGame()
            }
        }
    }
    
    func undo() {
        guard !userState.isSolved else { return }
        guard !undoManager.empty else { return }
        let currentMove = undoManager.currentItem
        undoManager.undo()
        let lastMove = undoManager.currentItem
        userState.applyUndo(state: lastMove)
        if let index = currentMove.selectedCellIndex {
            cellAnimations[index] = .undo
        }
    }
    
    func pauseResume() {
        isPaused.toggle()
        timer.toggle()
    }
    
    /// When only one number remains unsolved, auto fill the remaining value
    /// Uses cells without guesses: cells with value nil or < 0 (notes)
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
    
    func isNumberComplete(_ number: Int) -> Bool {
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
    
    public var empty: Bool {
        return history.isEmpty
    }
    
    public init(initialValue: A) {
        self.initialValue = initialValue
    }
    
    public mutating func undo() {
        guard !empty else { return }
        history.removeLast()
    }
}
