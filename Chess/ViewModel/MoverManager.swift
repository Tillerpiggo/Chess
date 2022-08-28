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
	private var game: GameModel
	var piece: PieceModel
	
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
	
	private func addOrRemovePattern(_ pattern: Pattern?, index: Int?, piece: PieceModel, movementType: Piece.MovementType, remove: Bool) {
        var patternModel: PatternModel? = nil
        
        // Only if the pattern is being added
        if let pattern = pattern { patternModel = converter.patternModel(from: pattern, mover: piece.mover!, captures: movementType == .captures) } // Make a new pattern
        
        // To prevent DRY:
        let addOrRemovePatternToFirstMove = {
            piece.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
            
            if piece.isCapturesSameAsNormal {
                piece.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
            }
        }
        
        switch movementType {
        case .normal:
            print("pieceModel patterns: \((piece.mover!.canMovePatterns!.array as! [PatternModel]).compactMap { Pattern(patternModel: $0)?.string })")
            
            piece.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
            
            
            if piece.isCapturesSameAsNormal {
                //pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
            }
            
            if piece.isFirstMoveSameAsNormal {
                addOrRemovePatternToFirstMove()
            }
        case .firstMove:
            addOrRemovePatternToFirstMove()
        case .captures:
            piece.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
            piece.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
        }
        
        saveContext()
        
        print("pieceModel patterns after: \((piece.mover!.canMovePatterns!.array as! [PatternModel]).compactMap { Pattern(patternModel: $0)?.string })")
	}
	
	init(moverManager: ModelManager<MoverModel>, firstMoveMoverManager: ModelManager<MoverModel>, converter: ModelConverter, game: GameModel, piece: PieceModel) {
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
