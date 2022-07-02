//
//  Pattern.swift
//  Chess
//
//  Created by Tyler Gee on 8/7/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import Foundation

struct Pattern: Identifiable {
	var type: PatternType
	
	var custom: [Position]
	var isRestricting: Bool
	
	// To makeup for lack of associated values alongside raw values:
	var rankDistance: Int?
	var fileDistance: Int?
	var directions: [Move.Direction]?
	
	var id = UUID()
	
	enum PatternType: Int, Equatable, Hashable {
		case custom = 0
		case horizontal, vertical, forwardSlash, backslash
		case withinDistance, outsideDistance, inDirections
		case pawn, pawnFirstMove, pawnCapture, knight, bishop, rook, queen, king
		
		static let types: [PatternType] = [.custom, .horizontal, .vertical, .forwardSlash, .backslash, .withinDistance, .outsideDistance, .inDirections, .pawn, .pawnFirstMove, .pawnCapture, .knight, .bishop, .rook, .queen, .king]
		
		var string: String {
			switch self {
			case .custom: return "Custom"
			case .horizontal: return "Horizontal Line"
			case .vertical: return "Vertical Line"
			case .forwardSlash: return "Diagonal Line /"
			case .backslash: return "Diagonal Line \\"
			case .withinDistance: return "All moves within a certain distance"
			case .outsideDistance: return "All moves beyond a certain distance"
			case .inDirections: return "All moves in direction(s)"
			case .pawn: return "Pawn (Normal)"
			case .pawnFirstMove: return "Pawn (First Move)"
			case .pawnCapture: return "Pawn (Capture)"
			case .knight: return "Knight"
			case .bishop: return "Bishop"
			case .rook: return "Rook"
			case .queen: return "Queen"
			case .king: return "King"
			}
		}
	}
	
	var string: String {
		switch type {
		case .custom, .horizontal, .vertical, .forwardSlash, .backslash,
			 .pawn, .pawnFirstMove, .pawnCapture, .knight, .bishop, .rook, .queen, .king:
			return type.string
		case .withinDistance:
			var string: String
			if isRestricting {
				string = "Must move further than \(rankDistance!) rank(s) or \(fileDistance!) file(s)"
			} else {
				string = "Can make any move within \(rankDistance!) rank(s), \(fileDistance!) file(s)"
			}
			
			return string
		case .outsideDistance:
			var string: String
			if isRestricting {
				string = "Can't move more than \(rankDistance!) rank(s) or \(fileDistance!) file(s)"
			} else {
				string = "Can make any move longer than \(rankDistance!) ranks(s) and \(fileDistance!) files(s)"
			}
			
			return string
		case .inDirections:
			var string: String
			if isRestricting {
				string = "Can't move \(directions!.map { $0.string.lowercased().appending(", ") }.joined().removingLast(2))"
			} else {
				string = "Can make any move going \(directions!.map { $0.string.lowercased().appending(", ") }.joined().removingLast(2))"
			}
			
			return string
		}
	}
	
	var canMove: (Move, Board) -> Bool {
		let canMove: (Move, Board) -> Bool
		
		switch type {
		case .custom: canMove = Pattern.custom(custom)
		case .horizontal: canMove = Pattern.horizontal
		case .vertical: canMove = Pattern.vertical
		case .forwardSlash: canMove = Pattern.forwardSlash
		case .backslash: canMove = Pattern.backslash
		case .withinDistance:
			if let rankDistance = rankDistance, let fileDistance = fileDistance {
				canMove = Pattern.withinDistance(ranks: rankDistance, files: fileDistance)
			} else {
				canMove = { (move, board) in false }
			}
		case .outsideDistance:
			if let rankDistance = rankDistance, let fileDistance = fileDistance {
				canMove = Pattern.outsideDistance(ranks: rankDistance, files: fileDistance)
			} else {
				canMove = { (move, board) in false }
			}
		case .inDirections:
			if let directions = directions {
				canMove = Pattern.inDirections(directions)
			} else {
				canMove = { (move, board) in false }
			}
		case .pawn: canMove = Pattern.pawn
		case .pawnFirstMove: canMove = Pattern.pawnFirstMove
		case .pawnCapture: canMove = Pattern.pawnCapture
		case .knight: canMove = Pattern.knight
		case .bishop: canMove = Pattern.bishop
		case .rook: canMove = Pattern.rook
		case .queen: canMove = Pattern.queen
		case .king: canMove = Pattern.king
		}
		
		if isRestricting {
			return { (move, board) in !canMove(move, board) }
		} else {
			return canMove
		}
	}
	
	init(_ type: PatternType, custom: [Position] = [], isRestricting: Bool = false, rankDistance: Int? = nil, fileDistance: Int? = nil, directions: [Move.Direction]? = nil) {
		self.type = type
		self.custom = custom
		self.isRestricting = isRestricting
		self.rankDistance = rankDistance
		self.fileDistance = fileDistance
		self.directions = directions
	}
	
	init?(patternModel: PatternModel) {
		guard let positionModelList = patternModel.custom?.sortedArray(using: [NSSortDescriptor(key: "rank", ascending: true)]) as? [PositionModel],
			  let type = PatternType(rawValue: Int(patternModel.type))
		else {
			print("Failed to initialize pattern out of patternModel")
			return nil
		}
		
		
		let custom = positionModelList.compactMap { Position(positionModel: $0) }
		

		var directions: [Move.Direction]?
		if let patternModelDirections = patternModel.directions {
			directions = patternModelDirections.compactMap { Move.Direction(rawValue: $0.intValue) }
		}
		
		self.init(
			type,
			custom: custom,
			isRestricting: patternModel.isRestricting,
			rankDistance: Int(patternModel.rankDistance),
			fileDistance: Int(patternModel.fileDistance),
			directions: directions
		)
	}
}

// Static vars for canMove
extension Pattern {
	
	static func custom(_ customPattern: [Position]) -> ((Move, Board) -> Bool) {
		return { (move, board) in
			for position in customPattern {
				if position.file == move.horizontalDistanceSigned,
				   position.rank == move.verticalDistanceSigned {
					return true
				}
			}
			
			return false
		}
	}
	
	static let horizontal: (Move, Board) -> Bool = { (move, board) in
		// Move must not move up at all
		if move.verticalDistance == 0 {
			// Move must not pass through occupied squares
			var path = [Position]()
			let leftmostFileInPath = min(move.start.file, move.end.file) + 1
			let rightmostFileInPath = max(move.start.file, move.end.file) - 1
			
			if rightmostFileInPath >= leftmostFileInPath {
				for file in leftmostFileInPath...rightmostFileInPath {
					path.append(Position(rank: move.start.rank, file: file))
				}
				
				var isPathObstructed = false
				path.compactMap({ board.squares[$0] }).forEach { square in
					if square.state != .empty { isPathObstructed = true }
				}
				
                return !isPathObstructed
			} else { // You're moving to an adjacent square
				return true
			}
			
		} else { // You're moving vertically
			return false
		}
	}
	
	// TODO - somehow reuse the code for horizontal with vertical
	static let vertical: (Move, Board) -> Bool = { (move, board) in
		// Move must not move horizontally at all
		if move.horizontalDistance == 0 {
			// Move must not pass through occupied squares
			var path = [Position]()
			let lowestRankInPath = min(move.start.rank, move.end.rank) + 1
			let highestRankInPath = max(move.start.rank, move.end.rank) - 1
			
			if highestRankInPath >= lowestRankInPath {
				for rank in lowestRankInPath...highestRankInPath {
					path.append(Position(rank: rank, file: move.start.file))
				}
				
				var isPathObstructed = false
				path.compactMap({ board.squares[$0] }).forEach { square in
					if square.state != .empty { isPathObstructed = true }
				}
				
				return !isPathObstructed
			} else { // You're moving to an adjacent square
				return true
			}
		} else { // You're moving horizontally
			return false
		}
	}
	
	// A diagonal going in the direction of a forward slash
	static let forwardSlash: (Move, Board) -> Bool = { (move, board) in
		// Must move equally horizontally and vertically
		if move.end.file - move.start.file == move.end.rank - move.start.rank {
			// Move must not pass through occupied squares
			var path = [Position]()
			let lowestPosition: Position
			let highestPosition: Position
			
			if move.start.rank < move.end.rank {
				lowestPosition = move.start.offset(ranks: 1, files: 1)
				highestPosition = move.end.offset(ranks: -1, files: -1)
			}
			else {
				lowestPosition = move.end.offset(ranks: 1, files: 1)
				highestPosition = move.start.offset(ranks: -1, files: -1)
			}
			
			if highestPosition.rank >= lowestPosition.rank {
				for rank in lowestPosition.rank...highestPosition.rank {
					path.append(Position(rank: rank, file: lowestPosition.file + (rank - lowestPosition.rank)))
				}
				
				var isPathObstructed = false
				path.compactMap({ board.squares[$0] }).forEach { square in
					if square.state != .empty {
						isPathObstructed = true
					}
				}
				
				return !isPathObstructed
			} else { // The square is adjacent
				return true
			}
		} else { // You aren't moving along the forward slash
			return false
		}
	}
	
	// A diagonal going in the direction of a backwards slash
	static let backslash: (Move, Board) -> Bool = { (move, board) in
		// Must move equally horizontally and vertically (but in opposite directions)
		// (Can't use distance b/c it is absolute value)
		if move.end.rank - move.start.rank == -1 * (move.end.file - move.start.file) {
			// Move must not pass through occupied squares
			var path = [Position]()
			let leftmostPosition: Position
			let rightmostPosition: Position
			
			if move.start.file < move.end.file {
				leftmostPosition = move.start.offset(ranks: -1, files: 1)
				rightmostPosition = move.end.offset(ranks: 1, files: -1)
			}
			else {
				leftmostPosition = move.end.offset(ranks: -1, files: 1)
				rightmostPosition = move.start.offset(ranks: 1, files: -1)
			}
			
			if rightmostPosition.file >= leftmostPosition.file {
				for file in leftmostPosition.file...rightmostPosition.file {
					path.append(Position(rank: leftmostPosition.rank - (file - leftmostPosition.file), file: file))
				}
				
				var isPathObstructed = false
				path.compactMap({ board.squares[$0] }).forEach { square in
					if square.state != .empty {
						isPathObstructed = true
					}
				}
				
				return !isPathObstructed
			} else { // The square is adjacent
				return true
			}
		} else { // You aren't moving along the backslash
			return false
		}
	}
	
	static let pawn: (Move, Board) -> Bool = { (move, board) in
		Pattern.vertical(move, board) && withinDistance(ranks: 1, files: 0)(move, board)
	}
	
	static let pawnFirstMove: (Move, Board) -> Bool = { (move, board) in
		Pattern.vertical(move, board) && withinDistance(ranks: 2, files: 0)(move, board)
	}
	
	static let pawnCapture: (Move, Board) -> Bool = { (move, board) in
		Pattern.bishop(move, board) && withinDistance(ranks: 1, files: 1)(move, board)
	}
	
	static let knight: (Move, Board) -> Bool = { (move, board) in
		move.horizontalDistance * move.verticalDistance == 2
	}
	
	static let bishop: (Move, Board) -> Bool = { (move, board) in
		forwardSlash(move, board) || backslash(move, board)
	}
	
	static let rook: (Move, Board) -> Bool = { (move, board) in
		horizontal(move, board) || vertical(move, board)
	}
	
	static let queen: (Move, Board) -> Bool = { (move, board) in
		bishop(move, board) || rook(move, board)
	}
	
	static let king: (Move, Board) -> Bool = { (move, board) in
		withinDistance(ranks: 1, files: 1)(move, board)
	}
	
	/// Returns all the squares within (inclusive) a certain number of ranks/files
	static func withinDistance(ranks: Int, files: Int) -> ((Move, Board) -> Bool) {
		return { (move, board) in
			move.horizontalDistance <= files && move.verticalDistance <= ranks
		}
	}
	
	/// Returns all the squares beyond (exclusive) a certain number of ranks/files. Primarily used as a restriction.
	static func outsideDistance(ranks: Int, files: Int) -> ((Move, Board) -> Bool) {
		return { (move, board) in
			return move.horizontalDistance > files || move.verticalDistance > ranks
		}
	}
	
	/// Returns all squares in a certain direction. Primarily used as a restriction.
	static func inDirections(_ directions: [Move.Direction]) -> ((Move, Board) -> Bool) {
		return { (move, board) in
			
			//print("move: \(move)")
			
			// If the move goes in a direction that is listed, return true
			for direction in move.directions {
				if directions.contains(direction) {
					// print("move contains direction: \(direction)")
					return true
				}
			}
			
			//print("move is not in the direction. Move directions: \(move.directions). Directions: \(directions)")
			
			return false
		}
	}
}

extension Pattern: Equatable {
	static func == (lhs: Pattern, rhs: Pattern) -> Bool {
		return lhs.type == rhs.type && lhs.custom == rhs.custom
	}
}
