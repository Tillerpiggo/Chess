//
//  PlayView.swift
//  Chess
//
//  Created by Tyler on 10/7/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PlayView: View {
    
    @EnvironmentObject var gameStore: GameManager
    @State var isPresentingCreateGameView = false
    @State var isPresentingGameView = false
    @State var game: Game?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.boardGreen)
                    .frame(height: 80)
                Button("Create a Game") {
                    isPresentingCreateGameView = true
                }
                
                if let game = game {
                    GameView(game: GameViewModel(game: game))
                        .frame(width: geometry.size.width)
                }
            }
        }
        .sheet(isPresented: $isPresentingCreateGameView) {
            CreateGameView(isPresented: $isPresentingCreateGameView) { (game) in
                self.game = game
                print("game.name: \(game.name)")
            }
                .environmentObject(gameStore)
        }
    }
}
