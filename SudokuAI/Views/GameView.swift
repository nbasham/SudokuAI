import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showSolvedAlert = false
    var body: some View {
        VStack {
            BoardView()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
            HStack {
                GuessPickerView()
                    .aspectRatio(1, contentMode: .fit)
                NotesPickerView()
                    .aspectRatio(1, contentMode: .fit)
            }
            Spacer()
        }
        .background(Color.gray.opacity(0.3))
        .alert("Puzzle Solved!", isPresented: $viewModel.solved) {
            Button("OK", role: .cancel) {
            }
        }
    }
}

#Preview {
    let viewModel = GameViewModel()
    GameView()
        .environmentObject(viewModel)
        .environmentObject(viewModel.userState)
}
