import SwiftUI

struct ControlView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState
    @State private var showSettings = false

    var body: some View {
        HStack(spacing: 0) {
            Text("\(SystemSettings.level.description)")
                .font(.title2.bold())
                .foregroundColor(Color(.systemGray4).opacity(0.8))
            Spacer()
            Button("", systemImage: "arrow.uturn.backward.circle") {
                viewModel.undo()
            }
            Spacer()
            Button("", systemImage: viewModel.isPaused ? "play.circle" : "pause.circle") {
                viewModel.pauseResume()
            }
            Spacer()
            Button("", systemImage: "gearshape") {
                viewModel.pauseResume()
                showSettings.toggle()
            }
            Spacer()
            Text("\(Int(userState.elapsed).timerValue)")
                .monospaced()
                .foregroundColor(Color(.systemGray4).opacity(0.8))
        }
        .padding(.horizontal)
        .padding(.horizontal)
        .sheet(isPresented: $showSettings) {
            SettingsView()
            .presentationDetents([.fraction(0.95)])
        }    }
}

#Preview {
    let viewModel = GameViewModel(puzzleId: "1")
    ControlView()
        .environmentObject(viewModel)
        .environmentObject(viewModel.userState)
}
