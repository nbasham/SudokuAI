//
//  GameView.swift
//  SudokuAI
//
//  Created by Norman Basham on 6/15/25.
//

import SwiftUI

struct GameView: View {
    let userState: SudokuUserState = {
        let u = SudokuUserState(puzzleId: "1")
        u.note(5, at: 0)
        return u
    }()
    var body: some View {
        VStack {
            SudokuBoardView(userState: userState)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
            Text("hi")
            HStack {
                Color.orange
                    .aspectRatio(1, contentMode: .fit)
                Color.yellow
                    .aspectRatio(1, contentMode: .fit)
            }
            Spacer()
        }
        .background(Color.gray.opacity(0.3))
    }
}

#Preview {
    GameView()
}
