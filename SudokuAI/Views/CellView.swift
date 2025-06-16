import SwiftUI
import Observation

struct CellView: View {
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