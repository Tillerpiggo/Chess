//
//  BoardStore.swift
//  Chess
//
//  Created by Tyler Gee on 8/3/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

/// Handles fetching GameModels from CoreData and provides an interface for adding, editing, and deleting them.
/// Used by views when they need to access all of the games currently saved in the app.
class CoreDataGameManager: GameManager {
	@Published var games = [Game]()
	
	
	// (replacable with test data as well)
	private var gameManager: ModelManager<GameModel>
	private var cancellable: AnyCancellable?
	
	private var converter: ModelConverter { gameManager.converter }
	private func saveContext() { gameManager.save() }
	private func delete(_ object: NSManagedObject) { gameManager.delete(object) }
    
    func pieceManager(for game: GameModel) -> PieceManager {
        let modelManager = gameManager.pieceManager(for: game)
        let pieceManager = PieceManager(pieceManager: modelManager, converter: converter, game: game)
        
        return pieceManager
    }
	
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
	
//	func updateGame(_ game: Game) {
//		if let gameModel = converter.retrieveGameModel(game) {
//			gameModel.name = game.name
//			gameModel.board = converter.boardModel(from: game.board)
//			gameModel.players = converter.playerModelSet(from: game.players)
//            //gameModel.pieces = converter.pieceModelSet(from: game.pieces, in: gameModel)
//			saveContext()
//
//            print("updating game!")
//		}
//	}
	
	func deleteGame(_ game: Game) {
		if let gameModel = converter.retrieveGameModel(game) {
			delete(gameModel)
			saveContext()
		}
	}
	
	init(gameManager: ModelManager<GameModel>) {
		self.gameManager = gameManager
		
		// Subscription to ModelManager<GameModel> to keep games updated
        self.cancellable = gameManager.models.eraseToAnyPublisher()
            .map { $0.compactMap { Game(gameModel: $0) }} // convert [GameModel] to [Game]
            .sink { games in
                self.games = games
            }
	}
}
