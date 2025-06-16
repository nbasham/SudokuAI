//
//  ContentView.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let viewModel = GameViewModel()
        GameView()
            .environmentObject(viewModel)
            .environmentObject(viewModel.userState)
    }
}

#Preview {
    let viewModel = GameViewModel()
    ContentView()
        .environmentObject(viewModel)
        .environmentObject(viewModel.userState)
}
