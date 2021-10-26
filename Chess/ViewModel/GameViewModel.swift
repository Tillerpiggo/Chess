//
//  StandardChessGame.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import SwiftUI

// Handles the Game View, where you can test a game or play it (only worries about the board)
class GameViewModel: ObservableObject {
	@Published private(set) var game: Game
	
	var squares: [[Square]] {
//        if game.activePlayer == .white {
//            return game.board.squares
//        } else {
//            return game.board.otherSideSquares
//        }
        return game.board.squares
	}
    
    var ranks: Int {
        return game.board.ranks
    }
    
    var files: Int {
        return game.board.files
    }
    
    var isReversed: Bool {
        return game.activePlayer == .black
    }
    
    var activePlayer: Player {
        return game.activePlayer
    }
	
	var legalMoves: [Position] {
		if let selectedSquare = selectedSquares.first, let piece = squares[selectedSquare]?.piece {
			return game.legalMoves(for: piece)
		} else {
			return []
		}
	}
	
	var gameState: Game.GameState { game.gameState }
	
	@Published private(set) var selectedSquares: [Position] = []
	
	init(game: Game) {
		self.game = game
	}
	
	func selectSquare(at position: Position) {
		print("selectedPosition: \(position)")
		
		// If you selected your own piece
		if game.board.squares[position]?.piece?.owner == game.activePlayer {
			selectedSquares = [position]
            
		// You selected an empty square or an enemy piece
		} else {
			
			// You already selected a square
			if let selectedSquare = selectedSquares.first, let move = Move(start: selectedSquare, end: position) {
				// Try to move and reset selected square
				game.move(move)
				self.selectedSquares = []
				print("made a move")
			}
		}
	}
	
	func legalMoves(for piece: Piece) -> [Position] { game.legalMoves(for: piece) }
}

/*
class StandardChessGame {
    var chessGame: Game = StandardChessGame.createNewStandardChessGame()
    
    private static func createNewStandardChessGame() -> Game {
        // TODO: - Fix this; produces random players each new game
        return Game(board: Board(pieces: []), players: [Player(), Player()])
    }
    
    struct StandardBoard: ChessBoard {
        
        // MARK: - Interface
        var allPieces: [Piece] {
            return pieces
        }
        
        func move(_ piece: Piece, to position: Position) -> Bool {
            let squareStateForPosition: (Position) -> SquareState = { position in
                self.squareState(of: position)
            }
            return piece.canMove(to: position, squareStateForPosition: squareStateForPosition)
        }
        
        init(pieces: [Piece]) {
            self.pieces = pieces
        }
        
        // MARK: - Private stuff
        private var pieces: [Piece]
        
        // Returns whether a given square is empty, occupied, or nonexitsent
        private func squareState(of position: Position) -> SquareState {
            guard position.rank < 8, position.file < 8 else { return .nonexistent }
            for piece in pieces {
                if piece.position == position {
                    return .occupied
                }
            }
            
            return .empty
        }
    }
    
    init() {
        // TODO - import players from some outside source
    }
}

enum SquareState {
    case nonexistent
    case empty
    case occupied
}
*/
