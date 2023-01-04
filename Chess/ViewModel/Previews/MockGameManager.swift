//
//  MockGameManager.swift
//  Chess
//
//  Created by Tyler Gee on 12/26/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import Foundation
import Combine

// Interface for GameManager so I'm able to use CoreDataGameManager for the actual view
// and use MockGameManager in previews
protocol GameManager: ObservableObject {
    
    var games: [Game] { get }
    
    func addGame(_ game: Game)
    
    func addGames(_ games: [Game])

    func deleteGame(_ game: Game)
    
}

// A GameManager with mock data and functionality used for previews/testing
class MockGameManager: GameManager {
    
    // Initializes a MockGameManager with two mock games:
    // A standard game (normal chess) and a custom game with a different name and the same board
    init() {
        let standardPieces = Board.standardPieces()
        let ids = Board.pieceIDs(pieces: standardPieces)
        let board = Board.standard(ids: ids)
        
        let pieces = standardPieces.map { $0.value }
        
        let standard = Game(
            board: board,
            pieces: pieces,
            players: [.white, .black],
            name: "Standard",
            description: "This is your normal, standard game of Chess. Nothing to see here!")
        
        var modified = standard
        modified.name = "Hello"
        
        games = [standard, modified]
    }
    
    
    var games: [Game]
    
    func addGame(_ game: Game) {
        games.append(game)
    }
    
    func addGames(_ games: [Game]) {
        self.games.append(contentsOf: games)
    }
    
    func deleteGame(_ game: Game) {
        games.removeAll(where: { $0.id == game.id })
    }
}
