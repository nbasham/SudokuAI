import SwiftUI


struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState
    @State private var showSolvedAlert = false
    @State private var showSolvedSheet = false
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if geometry.size.width > geometry.size.height {
                    GameViewLandscape()
                } else {
                    GameViewPortrait()
                }
            }
            if viewModel.isPaused {
                Color(.systemGray4)
                    .opacity(0.8)
                    .ignoresSafeArea()
                    .overlay(
                        Text("Paused")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    )
                    .onTapGesture {
                        viewModel.pauseResume()
                    }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.startGame()
            }
        }
        .background(Color.white.opacity(0.3))
        .sheet(isPresented: $viewModel.solved) {
            GameOverView()
                .environmentObject(viewModel)
            .presentationDetents([.fraction(0.95)])
        }
    }
}

struct GameViewLandscape: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                BoardView()
                ControlView()
                    .environmentObject(viewModel)
                    .environmentObject(userState)
                    .padding(.top, 2)
            }
            .padding(.top)
            VStack {
                ProgressView()
                    .environmentObject(viewModel)
                    .padding(.top)
                HStack {
                    PickerView(isNotes: false)
                        .aspectRatio(1, contentMode: .fit)
                    Spacer(minLength: 48)
                    PickerView(isNotes: true)
                        .aspectRatio(1, contentMode: .fit)
                }
                .padding()
            }
        }
    }
}

struct GameViewPortrait: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState

    var body: some View {
        VStack {
            Spacer()
            BoardView()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
            ControlView()
                .environmentObject(viewModel)
                .environmentObject(userState)

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
        .environmentObject(viewModel.userState)
}
