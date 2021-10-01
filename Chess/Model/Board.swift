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
	/// A 2D array of squares - a list of files ([file][rank]
	var squares: [[Square]]
	
	/*
	lazy var squareStateForPosition: (Position) -> Square.SquareState = { (position) -> Square.SquareState in
		return square(at: position, in: squares)?.state ?? .nonexistent
	}
*/
	var files: Int {
		return squares.count
	}
	
	var ranks: Int {
		return squares.first!.count
	}
	
    /// Performs a move and returns if the move succeeded or not
    mutating func move(move: Move, onlyAllowLegalMoves: Bool = true) -> Bool {
        if let boardState = boardState(after: move, onlyAllowLegalMoves: onlyAllowLegalMoves) {
			self = boardState
			return true
		} else {
			return false
		}
	}
	
	/// Returns the boardState after a given move. If the move is illegal, returns nil
    func boardState(after move: Move, onlyAllowLegalMoves: Bool = true) -> Board? {
		var boardState = squares
		guard let piece = squares[move.start]?.piece else { return nil }
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
		
        print("Hello?")
		if piece.canMove(to: move.end, in: self) || !onlyAllowLegalMoves {
			//print("new board")
            print("yesr")
			return newBoard
		} else {
            print("nope?")
			//print("Board state failed")
			return nil
		}
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
	
	func piece(at position: Position) -> Piece? { squares[position]?.piece }
	
	private func square(at position: Position, in squares: [[Square]]) -> Square? {
		guard position.file < squares.count && position.rank < squares[position.file].count else { return nil }
		
		return squares[position.file][position.rank]
	}
	
	mutating func setup(pieces: [Piece]) {
		for (fileIndex, file) in squares.enumerated() {
			for (rankIndex, rank) in file.enumerated()  {
				if let pieceID = squares[fileIndex][rankIndex].startingPieceID,
				   let pieceOwner = squares[fileIndex][rankIndex].startingPieceOwner {
					var piece = pieces.first(where: { $0.id == pieceID })
					piece?.position = Position(rank: rankIndex, file: fileIndex)
					piece?.owner = pieceOwner
					squares[fileIndex][rankIndex].setPiece(piece)
				}
			}
		}
	}
	
    static func empty(ranks: Int = 8, files: Int = 8, bottomLeftSquareColor: Square.SquareType = .dark) -> Board  {
		var squares = [[Square]]()
		
		// Create an empty board
		for fileIndex in 0..<files {
			var file = [Square]()
			for rankIndex in 0..<ranks {
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
    
    static func squareType(position: Position, bottomLeftSquareColor: Square.SquareType = .dark) -> Square.SquareType {
        let squareTypeNumber = bottomLeftSquareColor == .dark ? 1 : 0
        return (position.rank + position.file) % 2 == squareTypeNumber ? .light : .dark
    }
	
	static func standardPieces() -> [Square.StandardPieceType: Piece] {
		
		// The position of the piece. Since these pieces will be put in Game.pieces, their position on the board doesn't matter
		// However, the rank determines their position in the list.
		// This is just a fast way to get a position with a specific rank.
		let p: (Int) -> Position = { rank in Position(rank: rank, file: 0) }
		
		// The owner of the piece. Irrelevant since these are in Game.pieces.
		let o: Player = .white
		
		let pieces: [Square.StandardPieceType: Piece] = [
			.pawn: .pawn(position: p(0), owner: o),
			.knight: .knight(position: p(1), owner: o),
			.bishop: .bishop(position: p(2), owner: o),
			.rook: .rook(position: p(3), owner: o),
			.queen: .queen(position: p(4), owner: o),
			.king: .king(position: p(5), owner: o)
		]
		
		return pieces
	}
	
	static func pieceIDs(pieces: [Square.StandardPieceType: Piece]) -> [Square.StandardPieceType: UUID] {
		var standardIDs = [Square.StandardPieceType: UUID]()
		
		for (pieceType, piece) in pieces {
			standardIDs[pieceType] = piece.id
		}
		
		return standardIDs
	}
	
	static func standard(ids: [Square.StandardPieceType: UUID]) -> Board {
		// Create an empty board
		var squares = Board.empty().squares
		
		// Add in the pieces
		let backRank: [Square.StandardPieceType] = [
			.rook,
			.knight,
			.bishop,
			.queen,
			.king,
			.bishop,
			.knight,
			.rook
		]
		
		/*
		let blackBackRank: [Square.StandardPieceType] = [
			.rook(.black),
			.knight(.black),
			.bishop(.black),
			.queen(.black),
			.king(.black),
			.bishop(.black),
			.knight(.black),
			.rook(.black)
		]
*/
		
		for (fileIndex, _) in squares.enumerated() {
			squares[fileIndex][0].setPiece(backRank[fileIndex], owner: .white, id: ids[backRank[fileIndex]]!)
			squares[fileIndex][1].setPiece(.pawn, owner: .white, id: ids[.pawn]!)
			squares[fileIndex][7].setPiece(backRank[fileIndex], owner: .black, id: ids[backRank[fileIndex]]!)
			squares[fileIndex][6].setPiece(.pawn, owner: .black, id: ids[.pawn]!)
		}
		
		return Board(squares: squares)
	}
	
	init(squares: [[Square]]) {
		self.squares = squares
	}
	
	init?(boardModel: BoardModel) {
        //print("initializing boradmodel")
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
        
        //print("squareList: \(squareList.count)")
        //print("numberOfRanks: \(numberOfRanks)")
        //print("numberOfFiles: \(numberOfFiles)")
		
		// Populate the array
		for square in squareList {
			squareArray[square.position.file][square.position.rank] = square
		}
		
		self.init(squares: squareArray)
	}
}


extension Board: Equatable {
	static func == (lhs: Board, rhs: Board) -> Bool {
		//print(lhs.squares.flatMap { $0.map { $0.piece?.mover.canMovePatterns.map { $0.type } ?? [] } })
		//print(rhs.squares.flatMap { $0.map { $0.piece?.mover.canMovePatterns.map { $0.type } ?? [] } })
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


