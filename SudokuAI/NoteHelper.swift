// NoteHelper.swift
// Utility for working with Sudoku notes (1...9) using an efficient internal representation.
import Foundation

public struct NoteHelper {
    /// Returns a value representing a single note (1...9).
    public static func noteValue(for note: Int) -> Int {
        guard (1...9).contains(note) else { return 0 }
        return 1 << (note - 1)
    }
    /// Checks if a note is present in notes.
    public static func contains(notes: Int, note: Int) -> Bool {
        let bit = noteValue(for: note)
        return (notes & bit) != 0
    }
    /// Returns notes with a note added (idempotent).
    public static func adding(notes: Int, note: Int) -> Int {
        let bit = noteValue(for: note)
        return notes | bit
    }
    /// Returns notes with a note removed (idempotent).
    public static func removing(notes: Int, note: Int) -> Int {
        let bit = noteValue(for: note)
        return notes & ~bit
    }
    /// Returns true if there are no notes set.
    public static func isEmpty(notes: Int) -> Bool {
        return notes == 0
    }
}
