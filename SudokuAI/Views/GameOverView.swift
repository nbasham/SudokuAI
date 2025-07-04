import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Puzzle Solved!")
                .font(.largeTitle.bold())
            if let score = viewModel.scores.last {
                Text("Score: \(score.score)")
                Text("Level: \(PuzzleLevel(rawValue: score.level)!.description)")
            }
            Text("Average: \(String(format: "%.2f", viewModel.scores.levelAverage))")
            Button("OK") {
                viewModel.gameOver()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    let viewModel = GameViewModel(puzzleId: "1")
    let userState = viewModel.userState
    GameOverView()
        .environmentObject(viewModel)
        .environmentObject(userState)
}
