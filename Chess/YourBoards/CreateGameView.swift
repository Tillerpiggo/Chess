//
//  CreateGameView.swift
//  Chess
//
//  Created by Tyler on 10/7/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct CreateGameView: View {
    
    @EnvironmentObject var gameStore: CoreDataGameManager
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    @Binding var isPlayingGame: Bool
    
    //@State private var board: Game
    @State private var gameSelection: Int = 0
    
    private var game: Game? {
        return gameStore.games[gameSelection]
    }
    
    // Fetch the pieces for this game in order to make it
    var didPressDone: (Game) -> Void
    
    var body: some View {
        
        ZStack {
            VStack {
                AddCancelHeader(
                    title: "Create a Game",
                    isAddEnabled: true,
                    onCancel: {
                        isPresented = false
                    },
                    onAdd: {
                        didPressDone(gameStore.games[gameSelection])
                        isPresented = false
                        isPlayingGame = true
                    },
                    includeCancelButton: true,
                    addButtonTitle: "Play"
                )
                
                Picker("Board", selection: $gameSelection) {
                    ForEach(0..<gameStore.games.count) { index in
                        Text(gameStore.games[index].name ?? "Untitled Game")
                    }
                }.pickerStyle(.inline)
                
                GeometryReader { geometry in
                    if let game = game {
                        BoardView(board: .constant(game.board), squareLength: (geometry.size.width - 20) / CGFloat(game.files), cornerRadius: 8)
                        .padding(.leading, 10)
                    }
                }
                
                Spacer()
            }
            
           
            
        }
    }
    
    init(isPresented: Binding<Bool>, isPlayingGame: Binding<Bool>, didPressDone: @escaping (Game) -> Void) {
        self._isPresented = isPresented
        self._isPlayingGame = isPlayingGame
        self.didPressDone = didPressDone
    }
}
