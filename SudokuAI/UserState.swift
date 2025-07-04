import Foundation
import Combine

class UserState: ObservableObject, Codable {
    var puzzleId: SudokuPuzzle.ID
    @Published var selectedCellIndex: Int?
    @Published var selectedNumber: Int?
    @Published var elapsed: TimeInterval = 0
    @Published private(set) var boardState: [Int?]
    var puzzle: SudokuPuzzle {
        PuzzleStore.getPuzzle(id: puzzleId)
    }
    
    enum CodingKeys: String, CodingKey {
        case puzzleId
        case selectedCellIndex
        case selectedNumber
        case elapsed
        case boardState
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        puzzleId = try container.decode(SudokuPuzzle.ID.self, forKey: .puzzleId)
        selectedCellIndex = try container.decodeIfPresent(Int.self, forKey: .selectedCellIndex)
        selectedNumber = try container.decodeIfPresent(Int.self, forKey: .selectedNumber)
        elapsed = try container.decode(Double.self, forKey: .elapsed)
        boardState = try container.decode([Int?].self, forKey: .boardState)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(puzzleId, forKey: .puzzleId)
        try container.encode(selectedCellIndex, forKey: .selectedCellIndex)
        try container.encode(selectedNumber, forKey: .selectedNumber)
        try container.encode(elapsed, forKey: .elapsed)
        try container.encode(boardState, forKey: .boardState)
    }
    
    init(puzzleId: SudokuPuzzle.ID, initialState: UserState? = nil) {
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
                self.selectedCellIndex = firstEditableCellIndex
            }
        }
    }
    
    var firstEditableCellIndex: Int? {
        puzzle.cells.firstIndex { $0 <= 9 }
    }
    var isSelectionEditable: Bool {
        guard let selectedCellIndex else { return false }
        return isCellEditable(selectedCellIndex)
    }
    func isCellEditable(_ index: Int) -> Bool {
        return puzzle.cells[index] <= 9
    }
    var isSolved: Bool {
        for index in 0...80 {
            let answer =  puzzle.cells[index] <= 9 ? puzzle.cells[index] : puzzle.cells[index] - 9
            if boardState[index] != answer {
                return false
            }
        }
        return true
    }
    
    /// Returns the number that should fill all empty cells if and only if all unguessed cells have the same solution number in the puzzle. Otherwise, returns nil.
    var onlyRemainingNumber: Int? {
        // Indices where user answer does not match the solution (i.e., still incomplete)
        let incompleteIndices = boardState.indices.filter { idx in
            let solution = (puzzle.cells[idx] > 9 ? puzzle.cells[idx] - 9 : puzzle.cells[idx])
            return boardState[idx] != solution
        }
        guard !incompleteIndices.isEmpty else { return nil }
        let solutionNumbers = incompleteIndices.map { idx in
            let val = puzzle.cells[idx]
            return (val > 9 ? val - 9 : val)
        }
        let first = solutionNumbers.first!
        return solutionNumbers.allSatisfy { $0 == first } ? first : nil
    }
    
    /// Returns the indices of all empty cells whose solution in the puzzle is the given number.
    func indicesForEmptyCells(solutionIs number: Int) -> [Int] {
        boardState.indices.filter { index in
            boardState[index] == nil && (puzzle.cells[index] > 9 ? puzzle.cells[index] - 9 : puzzle.cells[index]) == number
        }
    }
    
    /// Returns indices of cells without a user guess (nil or containing notes), for a given solution number.
    func indicesForCellsWithoutGuesses(solutionIs number: Int) -> [Int] {
        boardState.indices.filter { index in
            let value = boardState[index]
            return (value == nil || (value ?? 0) < 0) && (puzzle.cells[index] > 9 ? puzzle.cells[index] - 9 : puzzle.cells[index]) == number
        }
    }
    
    func isEditable(index: Int) -> Bool {
        return puzzle.cells[index] <= 9
    }
    
    func applyUndo(state: GameViewModel.UndoState) {
        self.boardState = state.boardState
        self.selectedCellIndex = state.selectedCellIndex
        self.selectedNumber = state.selectedNumber
    }

    private func updateCell(_ index: Int, with value: Int?) {
        guard index >= 0 && index < 81 else { return }
        boardState[index] = value
    }
    
    func guess(_ number: Int, at index: Int) -> Bool {
        guard index >= 0 && index < 81 else {
            print("ERROR: Invalid index passed to guess(): \(index)")
            return false
        }
        guard number >= 1 && number <= 9 else {
            print("ERROR: Invalid number passed to guess(): \(number)")
            return false
        }
        var value: Int? = number
        if (boardState[index] == number) {
            value = nil
        }
        updateCell(index, with: value)
        return value == puzzle.cells[index]
    }
    
    internal func note(_ number: Int, at index: Int) {
        guard index >= 0 && index < 81 else {
                print("ERROR: Invalid index passed to note(): \(index)")
                return
            }
        guard number >= 1 && number <= 9 else {
            print("ERROR: Invalid number passed to note(): \(number)")
            return
        }
        let cellValue = NoteHelper.add(number, cellValue: boardState[index])
        updateCell(index, with: cellValue)
    }
}

extension UserState {
    static func load(fromKey key: String) -> UserState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserState.self, from: data)
    }
    
    func save(toKey key: String) {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// Extension for UserState to add reset method as required by gameOver()
extension UserState {
    func reset(toPuzzleId puzzleId: String) {
        self.puzzleId = puzzleId
        self.elapsed = 0
        for index in 0...80 {
            let puzzleValue = puzzle.cells[index]
            if (puzzleValue > 9) {
                self.boardState[index] = puzzleValue - 9
            } else {
                self.boardState[index] = nil
            }
            self.selectedCellIndex = firstEditableCellIndex
            self.selectedCellIndex = nil
            self.selectedNumber = nil
        }
    }
}
