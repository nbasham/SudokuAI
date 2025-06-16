import XCTest
@testable import SudokuAI

@MainActor
class SudokuUserStateUserDefaultsTests: XCTestCase {
    static let testKey = "SudokuUserStateTestKey"

    func testSaveAndLoad() async throws {
        let original = SudokuUserState(puzzleId: "1")
        original.selectedCellIndex = 10
        original.selectedNumber = 7
        // Guess a number and note a number (exercises boardState changes)
        original.guess(3, at: 20)
        original.note(5, at: 21)

        // Act: Save and then load
        original.save(toKey: Self.testKey)
        let loaded = SudokuUserState.load(fromKey: Self.testKey)

        // Assert: Loaded state is not nil and matches expected fields
        XCTAssertNotNil(loaded, "Should load state from UserDefaults")
        XCTAssertEqual(loaded?.puzzleId, original.puzzleId)
        XCTAssertEqual(loaded?.selectedCellIndex, original.selectedCellIndex)
        XCTAssertEqual(loaded?.selectedNumber, original.selectedNumber)
        XCTAssertEqual(loaded?.boardState, original.boardState)

        // Clean up
        UserDefaults.standard.removeObject(forKey: Self.testKey)
    }

    func testLoadMissingKeyReturnsNil() async throws {
        let missingKey = "SudokuUserStateTestMissingKey"
        // Clean just in case
        UserDefaults.standard.removeObject(forKey: missingKey)
        let loaded = SudokuUserState.load(fromKey: missingKey)
        XCTAssertNil(loaded, "Should return nil for missing key")
    }
}
