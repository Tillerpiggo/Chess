//
//  ChessPiece.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation

/// A Chess Piece that knows how it can move, if it is captured, if it has moved, and the player that owns it(usually black/white, but possibly could have more players)
struct Piece: Identifiable {
	
	var id: UUID
	
    /// Who owns the piece. If this piece is placed on a board, this is literal. If this is in the games "pieces" field, then this denotes what owners the piece can have.
	var owner: Player
    
    /// Whether the piece has moved yet (mainly useful for pieces such as the Pawn)
	var hasMoved: Bool = false
	
	/// This is the position of a piece on the board. When used in Game.pieces, position.rank doubles as the order of the piece in the list, with 0 being first.
	var position: Position
	
	/// This determines if the piece is "important". The specific game gets to decide what this means. Typically, only the King is "important" and the game is over once the opponent
	/// has no legal moves and the "important" piece can be captured next game. This could also be used if there were multiple "important" pieces, and the game could
	/// determine if they need to be mated, captured, and if all must be or only some. The game could even ignore this entirely.
	var isImportant: Bool = false
	
	var mover: Mover
	var firstMoveMover: Mover // Tells the piece how to move if it is on the first move
	var isFirstMoveSameAsNormal: Bool
	var isCapturesSameAsNormal: Bool
    
    /// This determines where the piece needs to go in order to be promoted
    var promotionZone: [Position]
    
    /// This determines what pieces that piece can promote into
    var promotionPieces: [UUID]
	
	var name: String
	
	var imageName: String { image.imageName(owner: owner) }
	
	var image: PieceImage
	
	/// Returns if the piece `canMove` to a `position` from where it currently is
	func canMove(to position: Position, in board: Board) -> Bool {
		if let move = Move(start: self.position, end: position) {
			return canMove(move: move, in: board)
		} else {
			print("canMove: \(false)")
			return false
		}
	}
	
	private func canMove(move: Move, in board: Board) -> Bool {
		if board.squares[move.end]?.piece?.owner != self.owner { // You are moving to an empty square or capturing a piece
//            if board.squares[move.end]?.state == .occupied { // You are capturing a piece
//				return mover.canCapture(move, board)
//			} else { // You are moving to an empty square
//				// If it's the first move, use the firstMoveMover. If you've already moved, use the normal mover.
//				return hasMoved ? mover.canMove(move, board) : firstMoveMover.canMove(move, board)
//			}
            switch board.squares[move.end]?.state {
            case .occupied: return mover.canCapture(move, board)
            case .nonexistent: return false // TODO: add bool to allow some pieces to create squares
            default: return hasMoved ? mover.canMove(move, board) : firstMoveMover.canMove(move, board)
            }
		} else { // You are trying to capture your own piece
			// TODO: - insert cannibal check here (if piece is cannibal, then it can capture its own kind
			print("false")
			return false
		}
	}
	
    init(name: String, image: PieceImage, mover: Mover, position: Position, promotionZone: [Position] = [], promotionPieces: [UUID] = [], owner: Player, id: UUID = UUID()) {
		self.name = name
		self.image = image
		self.mover = mover
		self.firstMoveMover = mover
		self.isFirstMoveSameAsNormal = true
		self.isCapturesSameAsNormal = (mover.canMovePatterns == mover.canCapturePatterns)
		self.position = position
        self.promotionZone = promotionZone
        self.promotionPieces = promotionPieces
		self.owner = owner
		self.id = id
	}
	
    init(name: String, image: PieceImage, mover: Mover, firstMoveMover: Mover, position: Position, promotionZone: [Position] = [], promotionPieces: [UUID] = [], owner: Player, id: UUID = UUID()) {
		self.name = name
		self.image = image
		self.mover = mover
		self.firstMoveMover = firstMoveMover
		self.isFirstMoveSameAsNormal = (mover == firstMoveMover)
		self.isCapturesSameAsNormal = (mover.canMovePatterns == mover.canCapturePatterns)
		self.position = position
        self.promotionZone = promotionZone
        self.promotionPieces = promotionPieces
		self.owner = owner
		self.id = id
	}
	
	init?(pieceModel: PieceModel) {
		guard
			let name = pieceModel.name,
			let image = PieceImage(rawValue: Int(pieceModel.pieceImage)),
			let positionModel = pieceModel.position, let position = Position(positionModel: positionModel),
			let playerModel = pieceModel.owner, let owner = Player(rawValue: Int(playerModel.player)),
            let promotionZoneModels = pieceModel.promotionZone?.array as? [PositionModel],
            let promotionPieceModels = pieceModel.promotionPieces as? [UUID],
			let id = pieceModel.id
			//let moverModel = pieceModel.mover, let mover = Mover(moverModel: moverModel),
			//let firstMoveMoverModel = pieceModel.firstMoveMover, let firstMoveMover = Mover(moverModel: firstMoveMoverModel)
		else {
			print("Failed to initialize piece from pieceModel")
			return nil
		}
		
		guard let moverModel = pieceModel.mover,
			  let firstMoveMoverModel = pieceModel.firstMoveMover
		else {
			print("The fuck up was early")
			return nil
		}
		
		guard let mover = Mover(moverModel: moverModel), let firstMoveMover = Mover(moverModel: firstMoveMoverModel) else {
			print("The fuck up was later")
			return nil
		}
		
		self.name = name
		self.image = image
		
        // Movers
		self.mover = mover
		self.firstMoveMover = firstMoveMover
		self.isFirstMoveSameAsNormal = pieceModel.isFirstMoveSameAsNormal
		self.isCapturesSameAsNormal = pieceModel.isCapturesSameAsNormal
        
        
		
        
        // Promotion
        self.promotionZone = promotionZoneModels.compactMap { Position(positionModel: $0) }
        self.promotionPieces = promotionPieceModels
        
        self.position = position
		self.owner = owner
		self.hasMoved = pieceModel.hasMoved
		self.isImportant = pieceModel.isImportant
		self.id = id
	}
	
	// Default pieces (mainly put here to keep the names consistent)
	static func king(position: Position, owner: Player) -> Piece {
		var king = Piece(name: "King", image: .king, mover: Mover.king, position: position, owner: owner)
		king.isImportant = true
		
		return king
	}
	
	static func queen(position: Position, owner: Player) -> Piece {
		Piece(
			name: "Queen",
			image: .queen,
			mover: Mover.queen,
			position: position,
			owner: owner
		)
    }
	
	static func bishop(position: Position, owner: Player) -> Piece {
		Piece(
			name: "Bishop",
			image: .bishop,
			mover: Mover.bishop,
			position: position,
			owner: owner
		)
	}
	
	static func knight(position: Position, owner: Player) -> Piece {
		Piece(
			name: "Knight",
			image: .knight,
			mover: Mover.knight,
			position: position,
			owner: owner
		)
	}
	
	static func rook(position: Position, owner: Player) -> Piece {
		Piece(
			name: "Rook",
			image: .rook,
			mover: Mover.rook,
			position: position,
			owner: owner
		)
	}
    
    // For both pawns, promotion pieces must be specified in terms of the ID's of the other pieces
    static func whitePawn(position: Position) -> Piece {
        let promotionZone = (0...7).map { Position(rank: 7, file: $0) }
        
        return Piece(
            name: "Pawn (white)",
            image: .pawn,
            mover: Mover.whitePawn,
            firstMoveMover: Mover.whitePawnFirstMove,
            position: position,
            promotionZone: promotionZone,
            owner: .white
        )
    }
    
    static func blackPawn(position: Position) -> Piece {
        let promotionZone = (0...7).map { Position(rank: 0, file: $0) }
        
        return Piece(
            name: "Pawn (black)",
            image: .pawn,
            mover: Mover.blackPawn,
            firstMoveMover: Mover.blackPawnFirstMove,
            position: position,
            promotionZone: promotionZone,
            owner: .black
        )
    }
	
//	static func pawn(position: Position, owner: Player) -> Piece {
//		// If pawns are white, they should only go up, and if they are black they should only go down
//		let directionRestrictionPattern = Pattern(
//			.inDirections,
//			isRestricting: true,
//			directions: (owner == .white) ? [.down] : [.up]
//		)
//
//		return Piece(
//			name: "Pawn",
//			image: .pawn,
//			mover: Mover.pawn.appendingPatterns([directionRestrictionPattern]),
//			firstMoveMover: Mover.pawnFirstMove.appendingPatterns([directionRestrictionPattern]),
//			position: position,
//			owner: owner
//		)
//	}
	
	enum PieceImage: Int {
		case king = 0, queen = 1, bishop = 2,
			 knight = 3, rook = 4, pawn = 5
		
		func imageName(owner: Player) -> String {
			var imageName: String
			
			switch self {
			case .king: imageName = "king"
			case .queen: imageName = "queen"
			case .bishop: imageName = "bishop"
			case .knight: imageName = "knight"
			case .rook: imageName = "rook"
			case .pawn: imageName = "pawn"
			}
			
			if owner == .white { return "white_" + imageName }
			else { return "black_" + imageName }
		}
	}
	
	enum MovementType {
		case normal, firstMove, captures
		
		var string: String {
			switch self {
			case .normal: return "Normal"
			case .firstMove: return "First Move"
			case .captures: return "Captures"
			}
		}
	}
}

// This is primarily for XCTests, and not actual utility of equating pieces.
// So it checks for more than just id.
// TODO: Figure out a better way of expresing this.s
extension Piece: Equatable {
	static func == (lhs: Piece, rhs: Piece) -> Bool {
		
		if lhs.id != rhs.id { return false }
		if lhs.owner != rhs.owner { return false }
		if lhs.hasMoved != rhs.hasMoved { return false }
		if lhs.position != rhs.position { return false }
		if lhs.isImportant != rhs.isImportant { return false }
		if lhs.name != rhs.name { return false }
		if lhs.image != rhs.image { return false }
		if lhs.mover != rhs.mover {
			print("lhsPiece.name: \(lhs.name)")
			print("rhsPiece.name: \(rhs.name)")
			
			return false
		}
		if lhs.firstMoveMover != rhs.firstMoveMover { return false }
		
		return true
	}
}
