import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    var body: some View {
        VStack {
            SudokuBoardView()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
            HStack {
                GuessView()
                    .aspectRatio(1, contentMode: .fit)
                Color.yellow
                    .aspectRatio(1, contentMode: .fit)
            }
            Spacer()
        }
        .background(Color.gray.opacity(0.3))
    }
}

#Preview {
    let viewModel = GameViewModel()
    GameView()
        .environmentObject(viewModel)
        .environmentObject(viewModel.userState)
}
