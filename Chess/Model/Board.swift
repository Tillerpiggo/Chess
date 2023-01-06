//
//  ChessBoard.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation

/// A chess board that can tell what positions are allowed and which ones aren't.
struct Board {
	/// A 2D array of squares - a list of files ([file][rank])
	var squares: [[Square]]
    
    var bottomLeftSquareColor: Square.SquareType {
        let bottomLeftSquareColor = squares[Position(rank: 0, file: 0)]?.type ?? .dark
        print("bottomLeftSquareColor: \(bottomLeftSquareColor)")
        return bottomLeftSquareColor
    }
    
	var files: Int {
		return squares.count
	}
	
	var ranks: Int {
		return squares.first?.count ?? 0
	}
    
    var smallestSide: Int {
        return min(ranks, files)
    }
    
    var largestSide: Int {
        return max(ranks, files)
    }
    
    /// Returns the squares from the perspective of black, with black on the bottom side.
    var otherSideSquares: [[Square]] {
        return squares.map { $0.reversed() }.reversed();
    }
	
    /// Performs a move and returns if the move succeeded or not
    mutating func move(move: Move) -> Bool {
        if let boardState = afterMove(move) {
			self = boardState
			return true
		} else {
			return false
		}
	}
    
    /// Promotes the piece at the given square to the other piece
    mutating func promotePiece(at position: Position, to piece: Piece) {
        squares[position]?.setPiece(piece)
        squares[position]?.state = .occupied // just to make sure
    }
    
    /// Moves a piece and changes the startingPieceIDs
    mutating func moveSetup(move: Move) {
        if let boardState = boardStateSetup(after: move) {
            self = boardState
        }
    }
	
	/// Returns the boardState after a given move. If the move is illegal, returns nil
    func afterMove(_ move: Move) -> Board? {
		var boardState = squares
        guard let piece = squares[move.start]?.piece, piece.canMove(to: move.end, in: self) else { return nil }
        guard move.end.rank < ranks, move.end.rank >= 0, move.end.file < files, move.end.file >= 0 else {
            return nil
        }
		
		// Empty the starting square
		boardState[move.start]?.setPiece(nil)
		boardState[move.start]?.state = .empty
		
		// Move piece to ending square
		boardState[move.end]?.setPiece(piece)
		boardState[move.end]?.state = .occupied
		
		// Mark that the piece has moved
		boardState[move.end]?.pieceHasMoved()
		
		var newBoard = self
		newBoard.squares = boardState
		
        return newBoard
	}
    
    /// Returns the boardState after a given move changing the board setup.
    func boardStateSetup(after move: Move) -> Board? {
        var boardState = squares
        guard let piece = squares[move.start]?.piece else { return nil }
        guard move.end.rank < ranks, move.end.rank >= 0, move.end.file < files,
              move.end.file >= 0 else {
                  return nil
        }

        // Empty the starting square
        boardState[move.start]?.setPiece(nil)
        boardState[move.start]?.state = .empty
//        let startingPieceID = boardState[move.start]?.startingPieceID
//        let startingPieceOwner = boardState[move.start]?.startingPieceOwner
//        boardState[move.start]?.startingPieceID = nil
//        boardState[move.start]?.startingPieceOwner = nil

        // Setup piece in ending square
        boardState[move.end]?.setPiece(piece)
        boardState[move.end]?.state = .occupied
//        boardState[move.end]?.startingPieceID = startingPieceID
//        boardState[move.end]?.startingPieceOwner = startingPieceOwner

        var newBoard = self
        newBoard.squares = boardState

        return newBoard
    }
	
	func pieces(for player: Player) -> [Piece] {
		var pieces = [Piece]()
		
		for file in squares {
			for square in file {
				if let piece = square.piece, piece.owner == player {
					pieces.append(piece)
				}
			}
		}
		
		return pieces
	}
    
    func containsSquare(atPosition pos: Position) -> Bool {
        let positionIsInBounds = pos.file >= 0 && pos.file < files && pos.rank >= 0 && pos.rank < ranks
        let squareAtPositionExists = squares[pos]?.state != .nonexistent
        
        return positionIsInBounds && squareAtPositionExists
    }
	
	func piece(at position: Position) -> Piece? { squares[position]?.piece }
	
	private func square(at position: Position, in squares: [[Square]]) -> Square? {
		guard position.file < squares.count && position.rank < squares[position.file].count else { return nil }
		
		return squares[position.file][position.rank]
	}
	
//    mutating func setup(setupPosition: SetupPosition) {
//		for (fileIndex, file) in squares.enumerated() {
//			for (rankIndex, square) in file.enumerated()  {
//				if let pieceID = square.startingPieceID,
//                   let pieceOwner = square.startingPieceOwner {
//					var piece = pieces.first(where: { $0.id == pieceID })
//					//piece?.position = Position(rank: rankIndex, file: fileIndex)
//                    //piece?.id = UUID() // needs to be unique for ForEach()
//                    piece?.position = square.position
//					piece?.owner = pieceOwner
//					squares[fileIndex][rankIndex].setPiece(piece)
//				}
//			}
//		}
//        for piece in setupPosition.pieces {
//            squares[piece.position]?.setPiece(piece)
//        }
//	}
    
    mutating func setPiece(_ piece: Piece, at position: Position) {
        squares[piece.position]?.setPiece(piece)
    }
    
    static func squareType(position: Position, bottomLeftSquareColor: Square.SquareType = .dark) -> Square.SquareType {
        let squareTypeNumber = bottomLeftSquareColor == .dark ? 0 : 1
        return (position.rank + position.file) % 2 == squareTypeNumber ? .light : .dark
    }
	
//	static func standardPieces() -> [Piece] {
//
//		// The position of the piece. Since these pieces will be put in Game.pieces, their position on the board doesn't matter
//		// However, the rank determines their position in the list.
//		// This is just a fast way to get a position with a specific rank.
//		let p: (Int) -> Position = { rank in Position(rank: rank, file: 0) }
//
//		// The owner of the piece. All but the pawn can be either black or white
//		let o: Player = .blackOrWhite
//
//		var pieces = [
//			.whitePawn(position: p(0)),
//            .blackPawn(position: p(0)),
//			.knight(position: p(2), owner: o),
//			.bishop: .bishop(position: p(3), owner: o),
//			.rook: .rook(position: p(4), owner: o),
//			.queen: .queen(position: p(5), owner: o),
//			.king: .king(position: p(6), owner: o)
//		]
//
//
//        // Set up promotion pieces for white and black
//        let promotionPieceTypes: [Game.StandardPieceType] = [.knight, .bishop, .rook, .queen]
//        let promotionPieces: [UUID] = promotionPieceTypes.compactMap { pieces[$0]?.id }
//
//        var whitePawn = pieces[.whitePawn]!
//        whitePawn.promotionPieces = promotionPieces
//        pieces[.whitePawn] = whitePawn
//
//        var blackPawn = pieces[.blackPawn]!
//        blackPawn.promotionPieces = promotionPieces
//        pieces[.blackPawn] = blackPawn
//
//		return pieces
//	}
	
//	static func pieceIDs(pieces: [Game.StandardPieceType: Piece]) -> [Game.StandardPieceType: UUID] {
//		var standardIDs = [Game.StandardPieceType: UUID]()
//
//		for (pieceType, piece) in pieces {
//			standardIDs[pieceType] = piece.id
//		}
//
//		return standardIDs
//	}
//
//	static func standard(ids: [Game.StandardPieceType: UUID]) -> Board {
//		// Create an empty board
//		var squares = Board.emptyBoard().squares
//
//		// Add in the pieces
//		let backRank: [Game.StandardPieceType] = [
//			.rook,
//			.knight,
//			.bishop,
//			.queen,
//			.king,
//			.bishop,
//			.knight,
//			.rook
//		]
//
//		for (fileIndex, _) in squares.enumerated() {
//			squares[fileIndex][0].setPiece(backRank[fileIndex], owner: .white, id: ids[backRank[fileIndex]]!)
//			squares[fileIndex][1].setPiece(.whitePawn, owner: .white, id: ids[.whitePawn]!)
//			squares[fileIndex][7].setPiece(backRank[fileIndex], owner: .black, id: ids[backRank[fileIndex]]!)
//            squares[fileIndex][6].setPiece(.blackPawn, owner: .black, id: ids[.blackPawn]!)
//		}
//
//		return Board(squares: squares)
//	}
	
	init(squares: [[Square]]) {
		self.squares = squares
	}
    
    /// Creates a rectangular empty board with the given dimensions and bottom left square color
    static func emptyBoard(ranks: Int = 8, files: Int = 8, bottomLeftSquareColor: Square.SquareType = .dark) -> Board  {
        
        var squares = [[Square]]()
        
        for fileIndex in 0..<files {
            
            var file = [Square]()
            
            for rankIndex in 0..<ranks {
                let emptySquare = Square(state: .empty, piece: nil, position: position, type: Board.squareType()
                file.append(Square(
                                state: .empty,
                                piece: nil,
                                startingPieceID: nil,
                                startingPieceOwner: nil,
                                position: Position(rank: rankIndex, file: fileIndex),
                                type: Board.squareType(position: Position(rank: rankIndex, file: fileIndex), bottomLeftSquareColor: bottomLeftSquareColor))
                )
            }
            squares.append(file)
        }
        
        return Board(squares: squares)
    }
	
	init?(boardModel: BoardModel) {
		// Arbitrary sort parameter because it doesn't matter
		guard let squareModelList = boardModel.squares?.sortedArray(using: [NSSortDescriptor(key: "state", ascending: true)]) as? [SquareModel] else {
			print("Failed to initialize board out of boardModel")
			return nil
		}
		
		let squareList = squareModelList.compactMap { Square(squareModel: $0) }
		
		let numberOfRanks = (squareList.map { $0.position.rank }.max() ?? 0) + 1
		let numberOfFiles = (squareList.map { $0.position.file }.max() ?? 0) + 1
		
		// Create an empty square array of proper dimensions
		var squareArray = [[Square]]()
		for file in 0..<numberOfFiles {
			squareArray.append([Square]())
			for rank in 0..<numberOfRanks {
				squareArray[file].append(Square(state: .nonexistent, piece: nil, startingPieceID: nil, startingPieceOwner: nil, position: Position(rank: rank, file: file), type: .light))
			}
		}
		
		// Populate the array
		for square in squareList {
			squareArray[square.position.file][square.position.rank] = square
		}
		
		self.init(squares: squareArray)
	}
}


extension Board: Equatable {
	static func == (lhs: Board, rhs: Board) -> Bool {

        guard lhs.files == rhs.files && lhs.ranks == rhs.ranks else {
            return false
        }
        
		for (fileIndex, file) in lhs.squares.enumerated() {
			for (rankIndex, lhsSquare) in file.enumerated() {
				if lhsSquare != rhs.squares[fileIndex][rankIndex] {
					return false
				}
			}
		}
		
		return true
	}
}


