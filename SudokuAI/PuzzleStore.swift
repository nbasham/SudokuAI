import Foundation

struct PuzzleStore {
    static var dict: [String: SudokuPuzzle] = [
        "1": SudokuPuzzle(id: "1", csv: "5,11,15,10,9,3,4,17,7,1,7,17,14,4,2,6,3,9,13,18,3,6,7,8,14,1,11,12,4,1,2,17,6,7,18,5,15,5,9,3,1,16,8,11,13,7,17,2,9,5,4,10,15,3,2,3,14,7,15,10,9,13,8,9,6,4,8,11,14,3,7,10,8,1,7,4,3,18,11,5,15"),
        "2": SudokuPuzzle(id: "2", csv: "7,11,5,8,9,6,3,4,10,18,15,3,7,4,1,11,8,5,1,4,8,2,3,14,6,16,9,12,5,4,15,8,18,10,11,16,8,9,2,13,10,7,5,3,6,6,1,16,14,11,12,13,9,17,5,12,9,1,16,4,8,15,2,2,16,10,12,6,8,18,14,4,13,17,6,9,5,2,16,10,3"),
        //   almost complete == 3
        "3": SudokuPuzzle(id: "3", csv: "18,14,11,12,10,16,15,17,13,17,15,16,14,13,18,11,12,10,10,13,12,8,15,11,14,16,18,16,18,15,10,12,8,13,14,11,11,17,14,16,18,13,12,10,15,13,12,10,11,14,15,16,18,8,12,7,17,15,11,10,18,13,14,14,11,18,13,8,12,10,15,16,15,10,13,18,16,14,8,11,12")
    ]

    static func generatePuzze(id: String, revealCount: Int = 37) -> SudokuPuzzle {
        let cells = generateEncodedSudoku(clueCount: revealCount)
        return SudokuPuzzle(id: id, cells: cells)
   }
    
    static func getPuzzle(id: String, revealCount: Int = 37) -> SudokuPuzzle {
//        return dict["3"]! run with almost complete
        if let puzzle = dict[id] {
            return puzzle
        } else {
            let newPuzzle = generatePuzze(id: id, revealCount: revealCount)
            dict[newPuzzle.id] = newPuzzle
            return newPuzzle
        }
    }
    
    // MARK: – Public API
    
    /// Generates a Sudoku “puzzle” encoded in a single array of 81 integers:
    ///  - Clue cells are shown as (digit + 9):  1→10, …, 9→18
    ///  - Non‑clue cells are filled with the actual solution digit (1–9).
    /// The underlying puzzle (if you subtract 9 from any value ≥10) has exactly one solution.
    /// - Parameter clueCount: The number of clues (pre‑filled cells) to leave in the puzzle.
    /// - Returns: An array of 81 integers, each in 1…18, no zeros.
    static func generateEncodedSudoku(clueCount: Int) -> [Int] {
        // 1) Generate a complete solution
        let solution = generateCompleteSolution()
        
        // 2) Remove clues while preserving uniqueness
        var puzzle = solution
        let indices = Array(0..<81).shuffled()
        
        for idx in indices {
            // stop once we’ve carved down to the desired number of clues
            let currentClues = puzzle.filter { $0 >= 1 && $0 <= 9 }.count
            if currentClues <= clueCount { break }
            
            let backup = puzzle[idx]
            puzzle[idx] = 0  // mark it “empty” for testing
            
            // if removing it yields multiple solutions, restore
            var test = puzzle
            if countSolutions(on: &test, limit: 2) != 1 {
                puzzle[idx] = backup
            }
        }
        
        // 3) Encode: clue cells are (1–9), blanks are 0 → now map:
        //    − if >0 you have a clue → add 9
        //    − if 0 you have no clue → fill with solution digit
        return puzzle.enumerated().map { idx, cell in
            if cell > 0 {
                // was a clue
                return cell + 9
            } else {
                // blank → reveal the solution
                return solution[idx]
            }
        }
    }
    
    // MARK: – Complete Solution Generator
    
    /// Returns a fully solved 9×9 Sudoku as a flat array of 81 ints (each 1…9).
    private static func generateCompleteSolution() -> [Int] {
        var board = [Int](repeating: 0, count: 81)
        _ = solveBoard(&board)
        return board
    }
    
    // MARK: – Backtracking Solver
    
    @discardableResult
    private static func solveBoard(_ board: inout [Int]) -> Bool {
        guard let empty = board.firstIndex(of: 0) else { return true }
        let nums = Array(1...9).shuffled()
        for n in nums {
            if isPlacementValid(on: board, at: empty, with: n) {
                board[empty] = n
                if solveBoard(&board) { return true }
                board[empty] = 0
            }
        }
        return false
    }
    
    // MARK: – Uniqueness Checker
    
    private static func countSolutions(on board: inout [Int], limit: Int) -> Int {
        var found = 0
        func backtrack(_ b: inout [Int]) {
            if found >= limit { return }
            guard let empty = b.firstIndex(of: 0) else {
                found += 1
                return
            }
            for n in 1...9 {
                if isPlacementValid(on: b, at: empty, with: n) {
                    b[empty] = n
                    backtrack(&b)
                    b[empty] = 0
                    if found >= limit { return }
                }
            }
        }
        backtrack(&board)
        return found
    }
    
    // MARK: – Placement Validation
    
    private static func isPlacementValid(on board: [Int], at idx: Int, with num: Int) -> Bool {
        let row = idx / 9, col = idx % 9
        for i in 0..<9 {
            if board[row*9 + i] == num || board[i*9 + col] == num { return false }
        }
        let boxRow = (row/3)*3, boxCol = (col/3)*3
        for r in boxRow..<(boxRow+3) {
            for c in boxCol..<(boxCol+3) {
                if board[r*9 + c] == num { return false }
            }
        }
        return true
    }
}
