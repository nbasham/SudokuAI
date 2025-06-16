//
//  ContentView.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView()
            .environmentObject(GameViewModel())
    }
}

#Preview {
    ContentView()
}
