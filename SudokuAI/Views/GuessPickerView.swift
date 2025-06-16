import SwiftUI

struct GuessPickerView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var selectedNumber: Int? = nil

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

        VStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1...9, id: \.self) { number in
                    Button(action: { viewModel.userGuess(guess: number) }) {
                        Text("\(number)")
                            .font(.title)
                            .foregroundStyle(selectedNumber == number ? .white : .primary)
                            .frame(width: 44, height: 44)
                            .background(selectedNumber == number ? Color.blue : Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            if let selected = selectedNumber {
                Text("Selected: \(selected)")
                    .font(.subheadline)
                    .padding(.top, 12)
            }
        }
        .padding()
    }
}

#Preview {
    GuessPickerView()
}
