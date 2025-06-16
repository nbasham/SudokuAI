import SwiftUI
import Observation

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

struct SudokuBoardView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var userState: SudokuUserState
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 9)

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Color.white // Board background
                SudokuBoardGridBackground()
                SudokuBoardGrid()
                    .frame(width: size, height: size)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<81, id: \.self) { index in
                        SudokuCellView(cellValue: userState.boardState[index])
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

struct SudokuCellView: View {
    var cellValue: Int?
    var body: some View {
        ZStack {
            if let v = cellValue {
                if v > 0 {
                    Text("\(v)")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.black)
                } else if v < 0 {
                    NotesGridView(notesValue: v)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotesGridView: View {
    var notesValue: Int
    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width / 3
            ZStack {
                ForEach(1...9, id: \.self) { note in
                    if NoteHelper.contains(note, cellValue: notesValue) {
                        let row = (note - 1) / 3
                        let col = (note - 1) % 3
                        Text("\(note)")
                            .font(.system(size: size * 0.5))
                            .foregroundStyle(.gray)
                            .frame(width: size, height: size, alignment: .center)
                            .position(x: size * (CGFloat(col) + 0.5), y: size * (CGFloat(row) + 0.5))
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = GameViewModel()
    let userState = viewModel.userState
    SudokuBoardView()
        .environmentObject(viewModel)
        .environmentObject(userState)
}
