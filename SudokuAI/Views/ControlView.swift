import SwiftUI

struct ControlView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState
    @State private var showSettings = false

    var body: some View {
        HStack(spacing: 0) {
            Text("\(SystemSettings.level.description)")
            Spacer()
            Button("", systemImage: "arrow.uturn.backward.circle") {
                viewModel.undoManager.undo()
                let state = viewModel.undoManager.currentItem
                viewModel.userState.applyUndo(state: state)
            }
            Spacer()
            Button("", systemImage: "gearshape") {
                showSettings.toggle()
            }
            Spacer()
            Text("\(Int(userState.elapsed).timerValue)")
                .monospaced()
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
