//
//  ContentView.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    let viewModel = GameViewModel(puzzleId: UUID().uuidString)
    
    var body: some View {
        NavigationStack {
            GameView()
                .environmentObject(viewModel)
                .environmentObject(viewModel.userState)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("\(viewModel.puzzleTitle)")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Undo") {
                                viewModel.undoManager.undo()
                                let state = viewModel.undoManager.currentItem
                                viewModel.userState.applyUndo(state: state)
                            }
                            Button("Settings") { /* Settings action */ }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
        }
    }
}

#Preview {
    let viewModel = GameViewModel(puzzleId: "1")
    ContentView()
        .environmentObject(viewModel)
        .environmentObject(viewModel.userState)
}

// This function could be called from a button tap or from a preview, instead of running at the top level.
#if canImport(FoundationModels)
import FoundationModels
import Playgrounds

@available(iOS 26.0, *)
private func runPlaygroundFoundationModelDemo() async {
    let system = SystemLanguageModel.default
    guard system.isAvailable else {
        print("Foundation Model not available")
        return
    }

    let session = LanguageModelSession()
    let prompt = Prompt("Create a Connections puzzle, it will be displayed with a print statement.")
    do {
        let response = try await session.respond(to: prompt)
        print("🧠 Model says: \(response.content)")
    } catch {
        print("Error: \(error)")
    }
}
#endif
