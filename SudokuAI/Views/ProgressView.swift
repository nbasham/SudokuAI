import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var viewModel: GameViewModel
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...9, id: \.self) { digit in
                DigitGrid(digit: digit).padding(.horizontal, 3)
                    .onTapGesture {
                        if digit == viewModel.userState.selectedNumber {
                            viewModel.userState.selectedNumber = nil
                        } else {
                            viewModel.userState.selectedNumber = digit
                        }
                    }
            }
        }
        .padding(2)
        .background(Color.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
    
    struct DigitGrid: View {
        @EnvironmentObject var viewModel: GameViewModel
        let digit: Int
        
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
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<3) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<3) { col in
                            let subgrid = row * 3 + col
                            Rectangle()
                                .fill(subgridHasDigit(subgrid: subgrid) ? Color.accentColor.opacity(0.5) : Color.clear)
                                .border(Color.black.opacity(0.44))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                Text("\(digit)")
                    .font(.headline.bold())
                    .foregroundStyle(Color.primary.opacity(0.7))
                    .padding(2)
           }
        }
    }
}
