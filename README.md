Experiment writing a Sudoku app using Xcode 26 beta AI. The app uses SwiftUI, view models and environment objects for user state, game logic, and UI responsiveness.

A unique feature of this app is the way it encodes Sudoku boards. Each puzzle is stored as a flat array of 81 integers. Clue cells are shown by encoding their digits as values 10–18 (where 10 means clue-digit 1, 18 means clue-digit 9). Non-clue cells are filled with their solution digits (1–9), and empty cells are represented as nil (never zero), while user notes use values less than 1. Zero is never used. This encoding makes it easy to distinguish whether a cell is a clue, a user guess, or a note, and supports efficient puzzle validation and UI updates.

The puzzle generator uses a complete backtracking algorithm to ensure each puzzle has exactly one solution. It randomly selects which cells to reveal as clues, encodes them, and fills the rest with the solution for challenging but fair gameplay. Game level is determined by the number of clues initially shown. The game timer is recreated every time it is restarted, ensuring precise tracking for each new attempt. The app manages both curated and dynamically generated puzzles, adapting to difficulty settings via the number of clues.

The interface allows intuitive touch controls for entering guesses or notes, quick selection of numbers, and visual progress tracking. The UI supports double-tap gestures for undoing the last attempt. It also displays a progress grid that visually tracks where each number has already been used across the board, helping players strategize their next moves.

**TODO**


1. Scoring
1. Save game state



