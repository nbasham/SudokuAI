import SwiftUI

struct NotesPickerView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

        VStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1...9, id: \.self) { note in
                    Button(action: {
                        viewModel.setNote(note)
                    }) {
                        Text("\(note)")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

#Preview {
    NotesPickerView()
}
