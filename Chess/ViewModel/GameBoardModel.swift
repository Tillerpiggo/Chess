//
//  GameModel.swift
//  Chess
//
//  Created by Tyler Gee on 1/30/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import Foundation

struct GameBoardModel {
    var name: String
    var board: Board
    var pieces: [Piece]
    var players: [Player]
    
    private(set) var activePlayer: Player
    private(set) var gameState: GameState
    
    var id: UUID
    
    enum GameState {
        case onGoing, draw
        case victory(Player)
    }
    
    init(board: Board, pieces: [Piece], players: [Player], name: String) {
        self.name = name
        self.board = board
        self.pieces = pieces
        self.players = players
        self.activePlayer = players.first!
        self.gameState = .onGoing
        self.id = UUID()
    }
    
    // Performs a move on the board and 
    mutating func move(_ move: Move, onlyAllowLegalMoves: Bool = true) {
        
    }
    
}
