import SwiftUI

struct CellView: View {
    @State private var scale: CGFloat = 1.0
    var cellValue: Int?
    @Binding var cellAnimation: CellAnimationType
    private let animationTime: Double = 0.36

    var body: some View {
        ZStack {
            cellContent
        }
        .onChange(of: cellAnimation) { _, newValue in
            switch newValue {
            case .guess, .autoComplete:
                runScaleAnimation(to: 2.0, duration: animationTime) {
                }
            case .grid:
                runScaleAnimation(to: 0.8, duration: 0.25) {
                }
            case .none, .row, .col:
                break
            }
            cellAnimation = .none
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    private var cellContent: some View {
        Group {
            if let v = cellValue {
                if v > 0 {
                    Text("\(v)")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.black)
                        .scaleEffect(scale)
                } else if v < 0 {
                    NotesGridView(notesValue: v)
                }
            }
        }
    }
    
    private func runScaleAnimation(to targetScale: CGFloat, duration: Double, completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: duration)) {
            scale = targetScale
        }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            await MainActor.run {
                withAnimation(.easeInOut(duration: duration)) {
                    scale = 1.0
                }
                completion()
            }
        }
    }
}
