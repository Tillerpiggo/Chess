//
//  PieceManager.swift
//  Chess
//
//  Created by Tyler Gee on 9/1/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

// Handles fetching all of the pieces from a game and provides an interface for adding, editing, and deleting them.
class PieceManager: ObservableObject {
	
	@Published private(set) var pieces = [Piece]()
	private var game: Game
	private var converter: ModelConverter
	
	private var pieceManager: ModelManager<PieceModel>
	private var cancellable: AnyCancellable?
	
	private func saveContext() { pieceManager.save() }
	private func delete(_ object: NSManagedObject) { pieceManager.delete(object) }
	
	func moverManager(for piece: Piece) -> MoverManager {
		let modelManager = pieceManager.moverManager(for: piece, firstMove: false)
		let firstMoveModelManager = pieceManager.moverManager(for: piece, firstMove: true)
		let moverManager = MoverManager(moverManager: modelManager, firstMoveMoverManager: firstMoveModelManager, converter: converter, game: game, piece: piece)
		
		return moverManager
	}
	
	// MARK: - Interface
	
	func addPiece(_ piece: Piece) {
		if let gameModel = converter.retrieveGameModel(game) {
			gameModel.addToPieces(converter.pieceModel(from: piece, in: gameModel))
			saveContext()
		}
	}
	
	func removePiece(_ piece: Piece) {
		if let gameModel = converter.retrieveGameModel(game),
		   let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
			gameModel.removeFromPieces(pieceModel)
			saveContext()
		}
	}
	
	func removePiece(at indices: IndexSet) {
		let index = indices.map { $0 }.first!
		if let gameModel = converter.retrieveGameModel(game) {
			gameModel.removeFromPieces(at: index)
			saveContext()
		}
	}
	
	func renamePiece(_ piece: Piece, to name: String) {
		if	let gameModel = converter.retrieveGameModel(game),
			let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
			pieceModel.name = name
			saveContext()
		}
	}
	
	func movePiece(from source: IndexSet, to destination: Int) {
		let startingPosition = source.map { $0 }.first!
		
		if let gameModel = converter.retrieveGameModel(game), let pieceModel = gameModel.pieces?.object(at: startingPosition) as? PieceModel {
			
			gameModel.removeFromPieces(at: startingPosition)
			
			// If the piece is moving from start -> end, the insertion index will be lower than what it was
			if startingPosition < destination {
				gameModel.insertIntoPieces(pieceModel, at: destination - 1)
				
			// If the piece is moving from the end -> start, it doesn't affect insertion index
			} else {
				gameModel.insertIntoPieces(pieceModel, at: destination)
			}
			
			saveContext()
		}
	}
	
	init(pieceManager: ModelManager<PieceModel>, converter: ModelConverter, game: Game) {
		self.pieceManager = pieceManager
		self.converter = converter
		self.game = game
		
		// Subscription to ModelManager<PieceModel> to pieces of a game updated
		self.cancellable = pieceManager.models.eraseToAnyPublisher().sink { pieces in
			print("updated pieces to \(pieces.map { $0.position!.rank }), \(pieces.map { $0.name })")
			self.pieces = pieces.compactMap { Piece(pieceModel: $0) }
		}
	}
}