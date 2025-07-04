import SwiftUI

struct PickerView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let isNotes: Bool

    func notesText(number: Int) -> some View {
        Text("\(number)")
            .font(.subheadline)
            .foregroundStyle(.primary)
            .bold(!isNotes)
    }

    func guessText(number: Int) -> some View {
        Text("\(number)")
            .font(.title)
            .foregroundStyle(.primary)
            .bold(!isNotes)
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)

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
                        Group {
                            if isNotes {
                                notesText(number: number)
                            } else {
//                                HStack(spacing: 5) {
                                    guessText(number: number)
//                                    ProgressView.DigitGrid(digit: number)
//                                        .padding(3)
//                                }
//                                .frame(width: 74, height: 40)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .padding(.horizontal)
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
