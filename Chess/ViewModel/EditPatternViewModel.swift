//
//  EditPatternViewModel.swift
//  Chess
//
//  Created by Tyler Gee on 8/27/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

class EditPatternViewModel: ObservableObject {
	
	@Published var rankDistance: Int? {
		didSet { pattern.rankDistance = rankDistance }
	}
	
	@Published var fileDistance: Int? {
		didSet { pattern.fileDistance = fileDistance }
	}
	
	@Published var directions: [Move.Direction]? {
		didSet { pattern.directions = directions}
	}
	
	@Published var type: Pattern.PatternType {
		didSet {
			pattern.type = type
			
			switch type {
			case .withinDistance, .outsideDistance:
				if rankDistance == nil { rankDistance = 0 }
				if fileDistance == nil { fileDistance = 0 }
				directions = nil
			case .inDirections:
				if directions == nil { directions = [] }
				rankDistance = nil
				fileDistance = nil
			default:
				rankDistance = nil
				fileDistance = nil
				directions = nil
			}
		}
	}
	
	@Published var isRestricting: Bool {
		didSet { pattern.isRestricting = isRestricting }
	}
	
	var canMove: (Move, Board) -> Bool { pattern.canMove }
	
	private(set) var pattern: Pattern
	private var piece: Piece
	
	var squares: [[Square]] {
		var board = Board.empty(ranks: 7, files: 7)
		board.squares[3][3].setPiece(piece)
		
		return board.squares
	}
	
	var selectedSquares: [Position] {
		var sevenBySevenPositionGrid = [Position]()
		
		for file in 0..<7 {
			for rank in 0..<7 {
				let position = Position(rank: rank, file: file)
				
				if let move = Move(start: piece.position, end: position) {
					var canMove = self.canMove(move, Board.empty(ranks: 7, files: 7))
					
					if isRestricting {
						canMove.toggle()
					}
					
					if piece.position != position, canMove {
						sevenBySevenPositionGrid.append(Position(rank: rank, file: file))
					}
				}
			}
		}
		
		return sevenBySevenPositionGrid
	}
	
	init(pattern: Pattern, piece: Piece) {
		self.pattern = pattern
		self.piece = piece
		self.piece.position = Position(rank: 3, file: 3)
		
		self.rankDistance = pattern.rankDistance
		self.fileDistance = pattern.fileDistance
		self.directions = pattern.directions
		self.type = pattern.type
		self.isRestricting = pattern.isRestricting
	}
}

