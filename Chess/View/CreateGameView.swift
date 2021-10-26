//
//  CreateGameView.swift
//  Chess
//
//  Created by Tyler on 10/7/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct CreateGameView: View {
    
    @EnvironmentObject var gameStore: GameManager
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    
    @State private var board: Game
    @State private var boardSelection: Int = 0
    
    var game: Game {
        print("board.name: \(board.name)")
        return board
    }
    
    var didPressDone: (Game) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            AddCancelHeader(
                title: "Create a Game",
                isAddEnabled: true,
                onCancel: {
                    isPresented = false
                },
                onAdd: {
                    didPressDone(gameStore.games[boardSelection])
                    isPresented = false
                },
                includeCancelButton: true,
                addButtonTitle: "Play"
            )
            
            Picker("Board", selection: $boardSelection) {
                ForEach(0..<gameStore.games.count) { index in
                    Text(gameStore.games[index].name)
                }
            }
        }
        .onAppear {
            print("games: \(gameStore.games.count)")
        }
    }
    
    init(isPresented: Binding<Bool>, didPressDone: @escaping (Game) -> Void) {
        self._isPresented = isPresented
        self.didPressDone = didPressDone
        self._board = State<Game>(initialValue: Game.standard())
    }
}
