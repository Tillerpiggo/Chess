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
    
    // TODO: Refactor BoardView2 to not require a Binding (?)
    // I'm doing it for now because im not 100% on if the updating will work without it
    @Published var game: Game
    @Published private(set) var selectedSquares: [Position] = []
    
    var squares: [[Square]] {
        return game.board.squares
    }
    
    var ranks: Int {
        return game.board.ranks
    }

    var files: Int {
        return game.board.files
    }
    
    var bottomLeftSquareColor: Square.SquareType {
        return game.board.squares[Position(rank: 0, file: 0)]?.type ?? .dark
    }
    
    func onDrag(from startingPosition: Position, to endingPosition: Position) {
        if let move = Move(start: startingPosition, end: endingPosition), game.board.squares[endingPosition]?.state != .nonexistent {
            game.move(move)
        }
    }
    
    // If the game is promoting, promotes the promoting piece to the given choice
    func promoteTo(_ piece: Piece) {
        game.promoteTo(piece)
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
    var promotablePieces: [Piece] {
        switch game.gameState {
        case let .promoting(piece):
            return piece.promotionPieces.compactMap { promotionPiece in
                var promotionOption = promotionPiece
                promotionOption.owner = activePlayer
                
                return promotionOption
            }
        default: return []
        }
    }
    
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
