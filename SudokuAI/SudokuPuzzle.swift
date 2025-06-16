import Foundation

struct SudokuPuzzle: Identifiable {
    typealias ID = String
    let id: SudokuPuzzle.ID
    let cells: [Int]
    
    init(id: String, csv: String) {
        self.id = id
        self.cells = csv.split(separator: ",").map { Int($0)! }
    }
}
