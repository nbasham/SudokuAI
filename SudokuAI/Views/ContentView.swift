//
//  ContentView.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    let viewModel = GameViewModel()
    
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
    let viewModel = GameViewModel()
    ContentView()
        .environmentObject(viewModel)
        .environmentObject(viewModel.userState)
}
