//
//  BoardStore.swift
//  Chess
//
//  Created by Tyler Gee on 8/3/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

// Handles storing multiple game models and provides an interface for saving, editing, and deleting them. Automatically translates fetched game models into games so that views can understand it
// (so that I can keep the sweet functional programming of Movers without rewriting everything)
class GameManager: ObservableObject {
	//@Published private(set) var games = [Game]()
	@Published var games = [GameModel]()
	
	
	// (replacable with test data as well)
	private var gameManager: ModelManager<GameModel>
	private var cancellable: AnyCancellable?
	
	private var converter: ModelConverter { gameManager.converter }
	private func saveContext() { gameManager.save() }
	private func delete(_ object: NSManagedObject) { gameManager.delete(object) }
	
//	func pieceManager(for game: Game) -> PieceManager {
//		let modelManager = gameManager.pieceManager(for: game)
//		let pieceManager = PieceManager(pieceManager: modelManager, converter: converter, game: game)
//
//		return pieceManager
//	}
    
    func pieceManager(for game: GameModel) -> PieceManager {
        let modelManager = gameManager.pieceManager(for: game)
        let pieceManager = PieceManager(pieceManager: modelManager, converter: converter, game: game)
        
        return pieceManager
    }
    
    // Returns a game with the most up to date pieces, as obtained from a piece manager for the game
//    func updatedGame(_ game: Game) -> Game {
//        var newGame = game
//        let pieceManager = pieceManager(for: game)
//        newGame.pieces = pieceManager.pieces.compactMap { Piece(pieceModel: $0) }
//
//        return newGame
//    }
	
	// MARK: - Intents
	func addGame(_ game: Game) {
		let _ = converter.gameModel(from: game)
		saveContext()
	}
	
	func addGames(_ games: [Game]) {
		for game in games {
			let _ = converter.gameModel(from: game)
		}
		
		saveContext()
	}
	
	func updateGame(_ game: Game) {
		if let gameModel = converter.retrieveGameModel(game) {
			gameModel.name = game.name
			gameModel.board = converter.boardModel(from: game.board)
			gameModel.players = converter.playerModelSet(from: game.players)
            //gameModel.pieces = converter.pieceModelSet(from: game.pieces, in: gameModel)
			saveContext()

            print("updating game!")
		}
	}
	
	func deleteGame(_ game: Game) {
		if let gameModel = converter.retrieveGameModel(game) {
			delete(gameModel)
			saveContext()
		}
	}
	
	init(gameManager: ModelManager<GameModel>) {
		self.gameManager = gameManager
		
		// Subscription to ModelManager<GameModel> to keep games updated
		self.cancellable = gameManager.models.eraseToAnyPublisher().sink { games in
			print("updated games")
			self.games = games
		}
	}
}
