import SwiftUI
import Observation

struct BoardView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: UserState
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 9)

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Color.white // Board background
                SudokuBoardGridBackground()
                SudokuBoardGrid()
                    .frame(width: size, height: size)
                SelectedNumberHighlightOverlay(selectedNumber: userState.selectedNumber, boardState: userState.boardState)
                    .frame(width: size, height: size)
                SelectedCellHighlightOverlay(selectedCellIndex: userState.selectedCellIndex)
                    .frame(width: size, height: size)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<81, id: \.self) { index in
                        CellView(cellValue: userState.boardState[index],
                                 cellAnimation: $viewModel.cellAnimations[index],
                                 cellAttribute:  $viewModel.cellAttributes[index],
                                 noteAttributes: $viewModel.noteAttributes[index])
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                viewModel.boardTap(index: index)
                            }
                    }
                }
                .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
        }
        .padding(8)
    }
}

// Draws an alternate light gray background on every other grid
struct SudokuBoardGridBackground: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cell = size / 9
            let block = cell * 3
            ZStack {
                ForEach(0..<9) { blockIndex in
                    let blockRow = blockIndex / 3
                    let blockCol = blockIndex % 3
                    // Shade every other block (checker pattern)
                    if (blockRow + blockCol) % 2 == 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.13))
                            .frame(width: block, height: block)
                            .position(x: block * (CGFloat(blockCol) + 0.5),
                                      y: block * (CGFloat(blockRow) + 0.5))
                    }
                }
            }
        }
    }
}

struct SudokuBoardGrid: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cell = size / 9
            Canvas { context, _ in
                for i in 0...9 {
                    let width: CGFloat = (i % 3 == 0) ? 2 : 0.5
                    // vertical lines
                    let x = CGFloat(i) * cell
                    var vLine = Path()
                    vLine.move(to: CGPoint(x: x, y: 0))
                    vLine.addLine(to: CGPoint(x: x, y: size))
                    context.stroke(vLine, with: .color(.black), lineWidth: width)
                    // horizontal lines
                    let y = CGFloat(i) * cell
                    var hLine = Path()
                    hLine.move(to: CGPoint(x: 0, y: y))
                    hLine.addLine(to: CGPoint(x: size, y: y))
                    context.stroke(hLine, with: .color(.black), lineWidth: width)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

struct SelectedCellHighlightOverlay: View {
    let selectedCellIndex: Int?
    var body: some View {
        GeometryReader { geo in
            if let index = selectedCellIndex, index >= 0 && index < 81 {
                let size = min(geo.size.width, geo.size.height)
                let cell = size / 9
                let row = index / 9
                let col = index % 9
                Rectangle()
                    .fill(Color.blue.opacity(0.22))
                    .frame(width: cell, height: cell)
                    .position(x: cell * (CGFloat(col) + 0.5),
                              y: cell * (CGFloat(row) + 0.5))
            }
        }
        .allowsHitTesting(false) // So it doesn't block taps
    }
}

struct SelectedNumberHighlightOverlay: View {
    let selectedNumber: Int?
    let boardState: [Int?]
    var body: some View {
        GeometryReader { geo in
            if let value = selectedNumber, value != 0 {
                let size = min(geo.size.width, geo.size.height)
                let cell = size / 9
                ZStack {
                    ForEach(0..<81, id: \.self) { idx in
                        if boardState[idx] == value {
                            let row = idx / 9
                            let col = idx % 9
                            Rectangle()
                                .fill(Color.blue.opacity(0.45))
                                .frame(width: cell, height: cell)
                                .position(x: cell * (CGFloat(col) + 0.5),
                                          y: cell * (CGFloat(row) + 0.5))
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    let viewModel = GameViewModel()
    let userState = viewModel.userState
    BoardView()
        .environmentObject(viewModel)
        .environmentObject(userState)
}
