import SwiftUI

struct CellView: View {
    @State private var scale: CGFloat = 1.0
    @State private var showEmitter: Bool = false
    var cellValue: Int?
    @Binding var cellAnimation: CellAnimationType
    @Binding var cellAttribute: CellAttributeType
    @Binding var noteAttributes: [NoteAttributeType]
    private let animationTime: Double = 0.36

    var body: some View {
        ZStack {
            cellContent
        }
        .overlay(
            Group { if showEmitter { StarEmitterView(duration: 2 * animationTime).allowsHitTesting(false) } }
        )
        .onChange(of: cellAnimation) { _, newValue in
            switch newValue {
            case .guess:
                runScaleAnimation(to: 2.0, duration: animationTime) {}
            case .autoComplete:
                showEmitter = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2 * animationTime) {
                    showEmitter = false
                }
                runScaleAnimation(to: 2.0, duration: animationTime) {}
            case .complete:
                runScaleAnimation(to: 2.0, duration: animationTime) {}
            case .none:
                break
            }
            cellAnimation = .none
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    private var cellContent: some View {
        Group {
            if let value = cellValue {
                if value > 0 {
                    Text("\(value)")
                        .font(.system(size: 24, weight: cellAttribute == .initial ? .medium : .regular))
                        .foregroundStyle(cellAttribute == .incorrect ? .red : .black)
                        .scaleEffect(scale)
                } else if value < 0 {
                    NotesGridView(value: value, attributes: noteAttributes)
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

private struct StarEmitterView: View {
    let duration: Double
    @State private var animating = false
    // Simple star shape using SF Symbols
    private let starCount = 8
    private let colors: [Color] = [.yellow, .orange, .mint, .purple, .pink]

    var body: some View {
        ZStack {
            ForEach(0..<starCount, id: \.self) { i in
                let angle = Double(i) / Double(starCount) * 2 * .pi
                let distance: CGFloat = animating ? 64 : 0
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(colors[i % colors.count])
                    .opacity(animating ? 0 : 1)
                    .offset(x: CGFloat(cos(angle)) * distance, y: CGFloat(sin(angle)) * distance)
                    .scaleEffect(animating ? 1.2 : 0.3)
                    .animation(.easeOut(duration: duration).delay(0.03 * Double(i)), value: animating)
            }
        }
        .onAppear {
            animating = true
        }
    }
}
