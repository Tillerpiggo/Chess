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
    
    func promotionPieceManager(for piece: Piece) -> PieceManager {
        let modelManager = pieceManager.promotionPieceManager(for: piece)
        return PieceManager(pieceManager: modelManager, converter: converter, game: game)
    }
	
	// MARK: - Interface
	
    // TODO: Refactor gameModel to be a property of this class itself, so it isn't always recalculated (or just refactor the whole get game model and get pieceModel thing)
    
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
		if let gameModel = converter.retrieveGameModel(game),
			let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
			pieceModel.name = name
            objectWillChange.send()
			saveContext()
		}
	}
    
    func setPieceIsImportant(_ piece: Piece, to isImportant: Bool) {
        if let gameModel = converter.retrieveGameModel(game),
           let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
            pieceModel.isImportant = isImportant
            saveContext()
        }
    }
    
    func updatePiece(_ piece: Piece) {
        if let gameModel = converter.retrieveGameModel(game),
           let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
//            pieceModel.name = piece.name
//            pieceModel
            converter.makePieceModelMatch(piece: piece, game: gameModel, pieceModel: pieceModel)
            saveContext()
        }
    }
    
//    func setPieceIsImportant(_ piece: Piece, to isntImportant: Bool) {
//        if let gameModel = converter.retrieveGameModel(game),
//           let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
//            pieceModel.isntImportant = isntImportant
//            saveContext()
//        }
//    }
    
    func setPieceCanPromote(_ piece: Piece, to canPromote: Bool) {
        if let gameModel = converter.retrieveGameModel(game),
           let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
            pieceModel.canPromote = canPromote
            saveContext()
        }
    }
    
    func removePromotionPiece(_ pieceID: UUID, from piece: Piece) {
        print("removing piece")
        if let gameModel = converter.retrieveGameModel(game),
           let pieceModel = converter.retrievePieceModel(piece, from: gameModel),
           let promotionPieces = pieceModel.promotionPieces {
//            let index = pieceModel.promotionPieces as [PieceModel]
//            pieceModel.removeFrreomPromotionPieces
            //pieceModel.removeFromPromotionPieces(at: index)
//            pieceModel.promotion
            var removedPromotionPieces = promotionPieces
            removedPromotionPieces.removeAll { $0 == pieceID }
            pieceModel.promotionPieces = removedPromotionPieces
            objectWillChange.send()
            saveContext()
        }
    }
    
    func promotionPieces(for piece: Piece) -> [Piece] {
        return piece.promotionPieces.compactMap { id in pieces.first { piece in piece.id == id }}
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
    
//    /// Update the piece with the matching ID to have all of the same fields as the piece passed in to this function
//    func updatePiece(_ piece: Piece) {
//        if let gameModel = converter.retrieveGameModel(game),
//           let pieceModel = converter.retrievePieceModel(piece, from: gameModel) {
//            pieceModel.name = piece.name
//            print("updating piece")
//            //converter.updatePieceModel(pieceModel, toMatch: piece, in: gameModel)
//            saveContext()
//        }
//    }
	
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
