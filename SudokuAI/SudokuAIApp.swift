//
//  SudokuAIApp.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/9/25.
//

import SwiftUI

@main
struct SudokuAIApp: App {
    
    init() {
        SystemSettings.performFirstLaunchSetupIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .padding(0)
        }
    }
}
