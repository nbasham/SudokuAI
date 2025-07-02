import SwiftUI


struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState
    @State private var showSolvedAlert = false
    var body: some View {
        VStack {
            Spacer()
            BoardView()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
            Text("\(Int(userState.elapsed).timerValue)")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
                .padding(.trailing)

            HStack {
                PickerView(isNotes: false)
                    .aspectRatio(1, contentMode: .fit)
                Spacer(minLength: 48)
                PickerView(isNotes: true)
                    .aspectRatio(1, contentMode: .fit)
            }
            .padding()

            ProgressView()
                .environmentObject(viewModel)
                .padding(.top)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.startGame()
            }
        }
        .background(Color.white.opacity(0.3))
        .alert("Puzzle Solved!", isPresented: $viewModel.solved) {
            Button("OK", role: .cancel) {
                viewModel.gameOver()
            }
        }
    }
}

public extension Int {
    /// 96.timerValue, yeilds "1:36"
    var timerValue: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = (self % 3600) % 60
        let timeStr = hours == 0 ? "\(minutes):\(String(format: "%02d", seconds))" : "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        return timeStr
    }
}

#Preview {
    let viewModel = GameViewModel(puzzleId: "1")
    GameView()
        .environmentObject(viewModel)
}
