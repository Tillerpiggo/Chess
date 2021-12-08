//
//  MoverManager.swift
//  Chess
//
//  Created by Tyler Gee on 9/1/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

// Handles fetching of all of the patterns in a given mover and provides an interface for adding, editing, and deleting them
class MoverManager: ObservableObject {
	
	@Published private(set) var mover: Mover!
	@Published private(set) var firstMoveMover: Mover!
	private var converter: ModelConverter
	
	private var moverManager: ModelManager<MoverModel>
	private var firstMoveMoverManager: ModelManager<MoverModel>
	private var cancellables: [AnyCancellable]?
	private var game: Game
	var piece: Piece
	
	private func saveContext() { moverManager.save() }
	
	// MARK: - Interface
	
	func addPattern(_ pattern: Pattern, movementType: Piece.MovementType) {
		print("Pattern: \(pattern.string), piece: \(piece.name), movementType: \(movementType)")
		
		addOrRemovePattern(pattern, index: nil, piece: piece, movementType: movementType, remove: false)
	}
	
	func removePattern(at indices: IndexSet, movementType: Piece.MovementType) {
		let index = indices.map { $0 }.first!
		
		addOrRemovePattern(nil, index: index, piece: piece, movementType: movementType, remove: true)
	}
	
	private func addOrRemovePattern(_ pattern: Pattern?, index: Int?, piece: Piece, movementType: Piece.MovementType, remove: Bool) {
		if	let gameModel = converter.retrieveGameModel(game),
			let pieceModel = converter.retrievePieceModel(piece, from: gameModel)
		{
			
			var patternModel: PatternModel? = nil
			
			// Only if the pattern is being added
			if let pattern = pattern { patternModel = converter.patternModel(from: pattern, mover: pieceModel.mover!, captures: movementType == .captures) } // Make a new pattern
			
			// To prevent DRY:
			let addOrRemovePatternToFirstMove = {
				pieceModel.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				
				if piece.isCapturesSameAsNormal {
					pieceModel.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				}
			}
			
			switch movementType {
			case .normal:
				print("pieceModel patterns: \((pieceModel.mover!.canMovePatterns!.array as! [PatternModel]).compactMap { Pattern(patternModel: $0)?.string })")
				
				pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				
				
				if piece.isCapturesSameAsNormal {
					//pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				}
				
				if piece.isFirstMoveSameAsNormal {
					addOrRemovePatternToFirstMove()
				}
			case .firstMove:
				addOrRemovePatternToFirstMove()
			case .captures:
				pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				pieceModel.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
			}
			
			saveContext()
			
			print("pieceModel patterns after: \((pieceModel.mover!.canMovePatterns!.array as! [PatternModel]).compactMap { Pattern(patternModel: $0)?.string })")
		}
	}
	
	init(moverManager: ModelManager<MoverModel>, firstMoveMoverManager: ModelManager<MoverModel>, converter: ModelConverter, game: Game, piece: Piece) {
		self.moverManager = moverManager
		self.firstMoveMoverManager = moverManager
		self.converter = converter
		self.game = game
		self.piece = piece
		
		// Subscription to ModelManager<PatternModel> to the patterns of a game
		self.cancellables = [
			moverManager.models.eraseToAnyPublisher().sink { movers in
				self.mover = Mover(moverModel: movers.first!)!
			},
			firstMoveMoverManager.models.eraseToAnyPublisher().sink { movers in
				self.firstMoveMover = Mover(moverModel: movers.first!)!
			}
		]
	}
	
}
