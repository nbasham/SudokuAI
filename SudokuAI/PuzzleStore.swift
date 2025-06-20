import Foundation

struct PuzzleStore {
    static func getPuzze(id: String) -> SudokuPuzzle {
        if id == "1" {
            return SudokuPuzzle(id: "1", csv: "5,11,15,10,9,3,4,17,7,1,7,17,14,4,2,6,3,9,13,18,3,6,7,8,14,1,11,12,4,1,2,17,6,7,18,5,15,5,9,3,1,16,8,11,13,7,17,2,9,5,4,10,15,3,2,3,14,7,15,10,9,13,8,9,6,4,8,11,14,3,7,10,8,1,7,4,3,18,11,5,15")
        } else if id == "2" {
            return SudokuPuzzle(id: "2", csv: "7,11,5,8,9,6,3,4,10,18,15,3,7,4,1,11,8,5,1,4,8,2,3,14,6,16,9,12,5,4,15,8,18,10,11,16,8,9,2,13,10,7,5,3,6,6,1,16,14,11,12,13,9,17,5,12,9,1,16,4,8,15,2,2,16,10,12,6,8,18,14,4,13,17,6,9,5,2,16,10,3")
        } else if id == "3" {
            //  Almost complete
            return SudokuPuzzle(id: "2", csv: "18,14,11,12,10,16,15,17,13,17,15,16,14,13,18,11,12,10,10,13,12,8,15,11,14,16,18,16,18,15,10,12,8,13,14,11,11,17,14,16,18,13,12,10,15,13,12,10,11,14,15,16,18,8,12,7,17,15,11,10,18,13,14,14,11,18,13,8,12,10,15,16,15,10,13,18,16,14,8,11,12")
        }
        fatalError()
    }
}
