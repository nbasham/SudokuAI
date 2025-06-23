//
//  ContentView.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/9/25.
//

import SwiftUI
import Playgrounds

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

import FoundationModels

#Playground {
    if #available(iOS 26.0, *) {
        // Check availability
        let system = SystemLanguageModel.default
        guard system.isAvailable else {
            print("Foundation Model not available")
            return
        }
        
        // Create a session and prompt
        let session = LanguageModelSession()
        let prompt = Prompt("Create a Connections puzzle, it will be displayed with a print statement.")
        
        // Send prompt and await response
        let response = try await session.respond(to: prompt)
        
        // Show the result
        print("🧠 Model says: \(response.content)")
    }
}
