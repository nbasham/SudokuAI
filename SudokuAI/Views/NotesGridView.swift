import SwiftUI

struct NotesGridView: View {
    var value: Int
    var attributes: [CellAttributeType]
    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width / 3
            ZStack {
                ForEach(1...9, id: \.self) { note in
                    if NoteHelper.contains(note, cellValue: value) {
                        let row = (note - 1) / 3
                        let col = (note - 1) % 3
                        Text("\(note)")
                            .font(.system(size: size * 0.75))
                            .foregroundStyle(attributes[note-1] == .none ? .black : .red)
                            .frame(width: size, height: size, alignment: .center)
                            .position(x: size * (CGFloat(col) + 0.5), y: size * (CGFloat(row) + 0.5))
                    }
                }
            }
        }
    }
}
