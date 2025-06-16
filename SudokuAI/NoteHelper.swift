import Foundation

public struct NoteHelper {
    internal static func bitValue(_ note: Int) -> Int {
        1 << note
    }
    static func add(_ note: Int, cellValue: Int?) -> Int? {
        var value: Int = 0
        if let cellValue {
            if cellValue < 0  {
                value = abs(cellValue)
            }
        }
        value = value ^ bitValue(note)
        if value == 0 {
            return nil
        } else {
            return -value
        }
    }
    static func remove(_ note: Int, cellValue: Int?) -> Int? {
        var value: Int = abs(cellValue ?? 0)
        if let temp = cellValue, temp > 0 {
            print("Check UI, we shouldn't be removing a ntoe from a guess")
            return cellValue
        }
        value = value & ~bitValue(note)
        if value == 0 {
            return nil
        } else {
            return -value
        }
    }
    static func contains(_ note: Int, cellValue: Int?) -> Bool {
        guard let value = cellValue else { return false }
        guard value < 0 else { return false }
        return (value & (bitValue(note))) != 0
    }
    static func hasNotes(cellValue: Int?) -> Bool {
        guard let value = cellValue else { return false }
        guard value < 0 else { return false }
        return value != 0
    }
}
