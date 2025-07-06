import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...9, id: \.self) { digit in
                VStack(spacing: 0) {
                    DigitGrid(digit: digit, isSelected: userState.selectedNumber == digit, isComplete: viewModel.isNumberComplete(digit)).padding(.horizontal, 3)
                    DigitNumber(digit: digit, isSelected: userState.selectedNumber == digit)
                }
                    .onTapGesture {
                        if digit == viewModel.userState.selectedNumber {
                            viewModel.userState.selectedNumber = nil
                        } else {
                            viewModel.userState.selectedNumber = digit
                        }
                        viewModel.lastGuess = viewModel.userState.selectedNumber
                    }
            }
        }
        .padding(2)
        .background(Color.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    struct DigitNumber: View {
        let digit: Int
        let isSelected: Bool
        var body: some View {
            Text("\(digit)")
                .font(.callout.bold())
                .foregroundStyle(isSelected ? Color.accentColor.opacity(0.5) : Color(.systemGray4).opacity(0.5))
        }
    }

    struct DigitGrid: View {
        @EnvironmentObject var viewModel: GameViewModel
        @EnvironmentObject var userState: UserState
        let digit: Int
        let isSelected: Bool
        let isComplete: Bool

        func subgridHasDigit(subgrid: Int) -> Bool {
            // subgrid: 0 to 8 (left-to-right, top-to-bottom)
            // Each subgrid has its indices: 3x3
            let indices = indicesForSubgrid(subgrid)
            return indices.contains { idx in
                viewModel.userState.boardState[idx] == digit
            }
        }
        
        func indicesForSubgrid(_ subgrid: Int) -> [Int] {
            // subgrid 0: (row 0-2, col 0-2), 1: (row 0-2, col 3-5), ...
            let startRow = (subgrid / 3) * 3
            let startCol = (subgrid % 3) * 3
            var indices: [Int] = []
            for row in 0..<3 {
                for col in 0..<3 {
                    let idx = (startRow + row) * 9 + (startCol + col)
                    indices.append(idx)
                }
            }
            return indices
        }

        func fillColor(number: Int) -> Color {
            if isComplete {
                return Color.black.opacity(0.25)
            } else if subgridHasDigit(subgrid: number) {
//                if isSelected {
//                    return Color.accentColor.opacity(0.3)
//                }
                return Color.black.opacity(0.6)
            }
            return Color.black.opacity(0.25)
        }

        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<3) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<3) { col in
                            let subgrid = row * 3 + col
                            Rectangle()
                                .fill(fillColor(number: subgrid))
                                .border(Color.white.opacity(0.54))
                                .aspectRatio(1, contentMode: .fit)

                        }
                    }
                }
           }
        }
    }
}

#Preview {
    let viewModel = GameViewModel(puzzleId: "1")
    let userState = viewModel.userState
    ProgressView()
        .environmentObject(viewModel)
        .environmentObject(userState)
}

#Preview {
    let viewModel = GameViewModel(puzzleId: "1")
    let userState = viewModel.userState
    ForEach(1...9, id: \.self) { digit in
        ZStack {
           RoundedRectangle(cornerRadius: 7).fill(Color.black.opacity(0.125))
                .frame(width: 84, height: 48)
            HStack {
                ProgressView.DigitGrid(digit: digit, isSelected: digit == 1, isComplete: false).padding(.horizontal, 3)
                    .opacity(0.525)
                    .frame(width: 44, height: 44)
                Text("\(digit)")
                    .font(.title.bold())
                    .foregroundStyle(Color.black.opacity(0.75))
            }
        }
    }
        .environmentObject(viewModel)
        .environmentObject(userState)
}
