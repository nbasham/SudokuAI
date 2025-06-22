import SwiftUI

struct PickerView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let isNotes: Bool

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

        VStack {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...9, id: \.self) { number in
                    Button(action: {
                        if isNotes {
                            viewModel.setNote(number)
                        } else {
                            viewModel.setGuess(number)
                        }
                    }) {
                        Text("\(number)")
                            .font(isNotes ? .title3 : .title2)
                            .foregroundStyle(.primary)
                            .bold(!isNotes)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                }
            }
        }
    }
}

#Preview {
    HStack {
        PickerView(isNotes: false)
        PickerView(isNotes: true)
    }
}
