//
//  PlayView.swift
//  Chess
//
//  Created by Tyler on 10/7/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PlayView: View {
    
    @EnvironmentObject var gameStore: CoreDataGameManager
    @State var isPresentingCreateGameView = false
    @State var isPresentingGameView = false
    @State var isPlayingGame = false
    @State var game: Game?
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical) {
                    GeometryReader { geometry in
                            
                                
                            Button(action: {
                                isPresentingCreateGameView = true
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.theme.accent)
                                    Text("Create a Game").bold().foregroundColor(.white)
                                }
                            })
                            .frame(height: 60)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                    }
                    .navigationBarTitle(Text("Play"), displayMode: .large)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $isPresentingCreateGameView) {
                CreateGameView(isPresented: $isPresentingCreateGameView, isPlayingGame: $isPlayingGame) { (game) in
                    self.game = game
                    print("game.name: \(game.name)")
                }
                    .environmentObject(gameStore)
            }
            
            if let game = game {
                Color.white
                GameView(game: GameViewModel(game: game))
            }
        }
    }
}
