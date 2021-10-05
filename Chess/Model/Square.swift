//
//  Square.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation


struct Square: Equatable, Identifiable, Hashable {
    var state: SquareState
	private(set) var piece: Piece?
	var startingPieceID: UUID?
	var startingPieceOwner: Player?
    var position: Position {
        didSet {
            piece?.position = position
        }
    }
	var type: SquareType
    
    var id: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        // Combine everything but the player because the player has a mover which cannot become hashable. If this fails for some reason to uniquiely id a square, then add piece to the mix, and implement this special hashing for it.
        hasher.combine(state)
        hasher.combine(startingPieceID)
        hasher.combine(startingPieceOwner)
        hasher.combine(position)
        hasher.combine(type)
        hasher.combine(id)
    }
	
	// Ensures that the piece always has the same position as the square that it is on
	mutating func setPiece(_ piece: Piece?) {
		self.piece = piece
		self.piece?.position = self.position
		state = .occupied
	}
    
    // Sets the piece and also sets the square's startingPieceID and owner
    // to match the given piece
    mutating func setStartingPiece(_ piece: Piece?) {
        self.setPiece(piece)
        startingPieceID = piece?.id
        startingPieceOwner = piece?.owner
    }
	
	// Updates the square's piece so that it knows that piece has moved
	mutating func pieceHasMoved() {
		piece?.hasMoved = true
	}
	
	// This is just to make it elegant to define boards
	mutating func setPiece(_ standardPiece: StandardPieceType, owner: Player, id: UUID) {
		switch standardPiece {
		case .king:
			piece = Piece.king(position: position, owner: owner)
		case .queen:
			piece = Piece.queen(position: position, owner: owner)
		case .bishop:
			piece = Piece.bishop(position: position, owner: owner)
		case .knight:
			piece = Piece.knight(position: position, owner: owner)
		case .rook:
			piece = Piece.rook(position: position, owner: owner)
		case .pawn:
			piece = Piece.pawn(position: position, owner: owner)
		}
		
		piece?.id = id
		startingPieceID = id
		startingPieceOwner = piece?.owner
		
		state = .occupied
	}
	
	enum StandardPieceType: Hashable {
		case king, queen, bishop, knight, rook, pawn
	}
	///
    
	enum SquareState: Int {
        /// Square does not exist on the board
        case nonexistent = 0
        
        /// Square exists, but no pieces are on it
        case empty = 1
        
        /// Square exists and there is a piece on it
        case occupied = 2
    }
	
	enum SquareType: Int {
		case light = 0
		case dark = 1
	}
	
	init(state: SquareState, piece: Piece? = nil, startingPieceID: UUID? = nil, startingPieceOwner: Player? = nil, position: Position, type: SquareType) {
		self.state = state
		self.piece = piece
		self.startingPieceID = startingPieceID
		self.startingPieceOwner = startingPieceOwner
		self.position = position
		self.type = type
	}
	
	init?(squareModel: SquareModel) {
		guard
			let state = SquareState(rawValue: Int(squareModel.state)),
			let type = SquareType(rawValue: Int(squareModel.type)),
			let positionModel = squareModel.position, let position = Position(positionModel: positionModel)
		else {
			print("Failed to create square from squareModel")
			return nil
		}
		
		// Create the piece
		var squareModelPiece: Piece? = nil
		if let piece = squareModel.piece {
			squareModelPiece = Piece(pieceModel: piece)
			
			if squareModelPiece == nil {
				print("something fucked up big time")
			}
		}
		
		var startingPieceOwner: Player?
		if let player = squareModel.startingPieceOwner?.player { startingPieceOwner = Player(rawValue: Int(player)) }
		
		// Initialize
		self.init(
			state: state,
			piece: squareModelPiece,
			startingPieceID: squareModel.startingPieceID,
			startingPieceOwner: startingPieceOwner,
			position: position,
			type: type
		)
	}
}
