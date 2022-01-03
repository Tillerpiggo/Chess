//
//  PieceDetailViewModel.swift
//  Chess
//
//  Created by Tyler Gee on 8/27/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

class PieceDetailViewModel: ObservableObject {
	@Published var selectedMovementType: Piece.MovementType = .normal
	var movementTypes: [Piece.MovementType] = [.normal, .firstMove, .captures]
	
	// TODO: Refactor this code so it is shared with the code in EditPatternView
	var selectedSquares: [Position] {
		var sevenBySevenPositionGrid = [Position]()
		
		var canMove: (Move, Board) -> Bool
		switch selectedMovementType {
		case .normal: canMove = moverManager.mover.canMove
		case .firstMove: canMove = moverManager.firstMoveMover.canMove
		case .captures: canMove = moverManager.mover.canCapture
		}
		
		for file in 0..<7  {
			for rank in 0..<7  {
				let position = Position(rank: rank, file: file)
				if positionPiece.position != position, canMove(Move(start: positionPiece.position, end: position)!, Board.empty(ranks: 7, files: 7)) {
					sevenBySevenPositionGrid.append(Position(rank: rank, file: file))
				}
			}
		}
        
        sevenBySevenPositionGrid.append(Position(rank: 3, file: 3))
		
		return sevenBySevenPositionGrid
	}
    
    var board: Board {
        var board = Board.empty(ranks: 7, files: 7)
        board.squares[3][3].setPiece(positionPiece)
        
        return board
    }
	
	var patterns: [Pattern] {
		switch selectedMovementType {
		case .normal: return moverManager.mover.canMovePatterns
		case .firstMove: return moverManager.firstMoveMover.canMovePatterns
		case .captures: return moverManager.mover.canCapturePatterns
		}
	}
	
	func removePattern(at indices: IndexSet, movementType: Piece.MovementType) {
		moverManager.removePattern(at: indices, movementType: movementType)
	}
	
	func addPattern(_ pattern: Pattern, movementType: Piece.MovementType) {
		moverManager.addPattern(pattern, movementType: movementType)
	}
	
	@ObservedObject var moverManager: MoverManager
	var piece: Piece { moverManager.piece }
	private var positionPiece: Piece {
		var positionPiece = piece
		positionPiece.position = Position(rank: 3, file: 3)
		return positionPiece
	}
	
	init(moverManager: MoverManager) {
		self.moverManager = moverManager
	}
	
}
