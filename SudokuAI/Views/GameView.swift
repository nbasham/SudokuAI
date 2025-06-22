import SwiftUI



struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showSolvedAlert = false
    var body: some View {
        VStack {
            Spacer()
            BoardView()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)

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
        .background(Color.white.opacity(0.3))
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
}
