//
//  Mover.swift
//  Chess
//
//  Created by Tyler Gee on 2/16/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import Foundation

// Determines whether a piece can move to another position given a board state. Can be combined with other movers.
struct Mover {
	var canMovePatterns: [Pattern]
	var canCapturePatterns: [Pattern]
	
	var canMove: (Move, Board) -> Bool
	var canCapture: (Move, Board) -> Bool
	
	static func combine(_ canMove: @escaping (Move, Board) -> Bool, with otherCanMove: @escaping (Move, Board) -> Bool) -> ((Move, Board) -> Bool) {
		let combinedCanMove: (Move, Board) -> Bool = { (move, board) in
			return canMove(move, board) || otherCanMove(move, board)
		}
		
		return combinedCanMove
	}
	
	static func restrict(_ canMove: @escaping (Move, Board) -> Bool, with moveCondition: @escaping (Move, Board) -> Bool) -> ((Move, Board) -> Bool) {
		let conditionalCanMove: (Move, Board) -> Bool = { (move, board) in
			return moveCondition(move, board) && canMove(move, board)
		}
		
		return conditionalCanMove
	}
	
	
	// TODO: Consider refactoring this code to not use movers,
	// but rather directly use (Move, Board) -> Bool closures
	// Since it works now I'll move on, but it might be more efficient that way.
	static func canMove(patterns: [Pattern]) -> (Move, Board) -> Bool {
		var canMove: (Move, Board) -> Bool = { (move, board) in false } // Make it start out as not being able to move at all
		for pattern in patterns {
			if pattern.isRestricting {
				canMove = restrict(canMove, with: pattern.canMove)
			} else {
				canMove = combine(canMove, with: pattern.canMove)
			}
		}
		
        return canMove
	}
	
	func appendingPatterns(canMovePatterns: [Pattern], canCapturePatterns: [Pattern]) -> Mover {
		Mover(
			canMovePatterns: self.canMovePatterns.appending(canMovePatterns),
			canCapturePatterns: self.canCapturePatterns.appending(canCapturePatterns)
		)
	}
    
	// For convenience on appendingPatterns
	func appendingPatterns(_ patterns: [Pattern]) -> Mover {
		return self.appendingPatterns(canMovePatterns: patterns, canCapturePatterns: patterns)
	}
    
    // For even more convenience
    func appendingPattern(_ pattern: Pattern) -> Mover {
        return self.appendingPatterns([pattern])
    }
	
	init(canMovePatterns: [Pattern], canCapturePatterns: [Pattern]) {
		self.canMove = Mover.canMove(patterns: canMovePatterns)
		self.canCapture = Mover.canMove(patterns: canCapturePatterns)
		self.canMovePatterns = canMovePatterns
		self.canCapturePatterns = canCapturePatterns
	}
	
	
	init(patterns: [Pattern]) {
		self.init(canMovePatterns: patterns, canCapturePatterns: patterns)
	}
	
	// TODO: Refactor this. A mover should NOT have empty patterns
	// I want to make all of these private, but I can't
	// because methods that use them would have to be non-static
	// and then I can't use those methods within inits.
	init(canMove: @escaping (Move, Board) -> Bool, canCapture: @escaping (Move, Board) -> Bool, canMovePatterns: [Pattern] = [], canCapturePatterns: [Pattern] = []) {
		self.canMove = canMove
		self.canCapture = canCapture
		self.canMovePatterns = canMovePatterns
		self.canCapturePatterns = canCapturePatterns
	}
	
	init(canMove: @escaping (Move, Board) -> Bool) {
		self.init(canMove: canMove, canCapture: canMove)
	}
	
	init(customPattern: [Position]) {
		let canMove: (Move, Board) -> Bool = { (move, board) in
			for position in customPattern {
				if position.file == move.horizontalDistanceSigned,
				   position.rank == move.verticalDistanceSigned {
					return true
				}
			}
			
			return false
		}
		
		self.canMove = canMove
		self.canCapture = canMove
		self.canMovePatterns = []
		self.canCapturePatterns = []
	}
	
	init?(moverModel: MoverModel) {
		guard let canMovePatternsModel = moverModel.canMovePatterns?.array as? [PatternModel],
			  let canCapturePatternsModel = moverModel.canCapturePatterns?.array as? [PatternModel]
		else {
			return nil
		}
		
		let canMovePatterns = canMovePatternsModel.compactMap { Pattern(patternModel: $0) }
		
		let canCapturePatterns = canCapturePatternsModel.compactMap { Pattern(patternModel: $0) }
		
		self.init(canMovePatterns: canMovePatterns, canCapturePatterns: canCapturePatterns)
	}
}

// Standard piece implementations
// Implement with base patterns so that they are easily editable

extension Mover {
	
	private static let pawnCapturePatterns: [Pattern] = {
		var oneSquareDistanceRestriction = Pattern(
			.outsideDistance,
			isRestricting: true,
			rankDistance: 1,
			fileDistance: 1
		)
		
		return [Pattern(.forwardSlash), Pattern(.backslash), oneSquareDistanceRestriction]
	}()
	
	static let whitePawn: Mover = {
		var oneSquareDistanceRestriction = Pattern(
			.outsideDistance,
			isRestricting: true,
			rankDistance: 1,
			fileDistance: 0
        )
        
        var directionRestriction = Pattern(
            .inDirections,
            isRestricting: true,
            directions: [.down]
        )
		
		let canMovePatterns = [Pattern(.vertical), oneSquareDistanceRestriction]
		
        return Mover(canMovePatterns: canMovePatterns, canCapturePatterns: pawnCapturePatterns).appendingPattern(directionRestriction)
	}()
	
	static let whitePawnFirstMove: Mover = {
		var twoSquareDistanceRestriction = Pattern(
			.outsideDistance,
			isRestricting: true,
			rankDistance: 2,
			fileDistance: 0
		)
        
        var directionRestriction = Pattern(
            .inDirections,
            isRestricting: true,
            directions: [.down]
        )
		
		let canMovePatterns = [Pattern(.vertical), twoSquareDistanceRestriction]
		
        return Mover(canMovePatterns: canMovePatterns, canCapturePatterns: pawnCapturePatterns).appendingPattern(directionRestriction)
	}()
    
    static let blackPawn: Mover = {
        var oneSquareDistanceRestriction = Pattern(
            .outsideDistance,
            isRestricting: true,
            rankDistance: 1,
            fileDistance: 0
        )
        
        let canMovePatterns = [Pattern(.vertical), oneSquareDistanceRestriction]
        
        var directionRestriction = Pattern(
            .inDirections,
            isRestricting: true,
            directions: [.up]
        )
        
        return Mover(canMovePatterns: canMovePatterns, canCapturePatterns: pawnCapturePatterns).appendingPattern(directionRestriction)
    }()
    
    static let blackPawnFirstMove: Mover = {
        var twoSquareDistanceRestriction = Pattern(
            .outsideDistance,
            isRestricting: true,
            rankDistance: 2,
            fileDistance: 0
        )
        
        let canMovePatterns = [Pattern(.vertical), twoSquareDistanceRestriction]
        
        var directionRestriction = Pattern(
            .inDirections,
            isRestricting: true,
            directions: [.up]
        )
        
        return Mover(canMovePatterns: canMovePatterns, canCapturePatterns: pawnCapturePatterns).appendingPattern(directionRestriction)
    }()
	
	static let knight: Mover = { Mover(patterns: [Pattern(.knight)]) }()
	static let bishop: Mover = { Mover(patterns: [Pattern(.forwardSlash), Pattern(.backslash)]) }()
	static let rook: Mover = { Mover(patterns: [Pattern(.horizontal), Pattern(.vertical)]) }()
	static let queen: Mover = { Mover(patterns: [Pattern(.horizontal), Pattern(.vertical), Pattern(.forwardSlash), Pattern(.backslash)]) }()
	static let king: Mover = { Mover(patterns: [Pattern(.king)]) }()
}

extension Mover: Equatable {
	static func == (lhs: Mover, rhs: Mover) -> Bool {
		return lhs.canMovePatterns == rhs.canMovePatterns &&
			lhs.canCapturePatterns == rhs.canCapturePatterns
	}
}
