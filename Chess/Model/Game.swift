//
//  ChessGame.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation

struct Game: Identifiable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
	var name: String
    var board: Board
	var pieces: [Piece]
    var players: [Player]
    
    var ranks: Int { board.ranks }
    var files: Int { board.files }
    
    private(set) var activePlayer: Player
	private(set) var gameState: GameState
	
	let id: UUID
	
	enum GameState {
		case onGoing, draw
        case promoting(Piece)
		case victory(Player)
	}
    
    // If the game is promoting, promotes the promoting piece to the given piece
    mutating func promoteTo(_ piece: Piece) {
        switch gameState {
        case let .promoting(promotingPiece):
            board.promotePiece(at: promotingPiece.position, to: piece)
            gameState = .onGoing
            nextTurn()
        default: return
        }
    }

    // Performs a move on the board and changes the turn (if legal). If illegal, does nothing.
    mutating func move(_ move: Move, onlyAllowLegalMoves: Bool = true) {
        
        // || !onlyAllowLegalMoves effectively bypasses other restrictions
		guard board.squares[move.start]?.piece?.owner == activePlayer || !onlyAllowLegalMoves else { return }
		
        // Proceed if the move is legal OR if we don't care about move legality (and make sure it's possible on the board)
        if (isMoveLegal(move) || !onlyAllowLegalMoves), board.move(move: move) {
            
            // Check for promotion
            if let piece = board.squares[move.end]?.piece,
               piece.canPromote, !piece.promotionPieces.isEmpty, piece.promotionZone.contains(move.end) {
                gameState = .promoting(piece)
            } else {
                nextTurn()
            }
        }
    }
    
    // Goes to the next turn, by changing the active player and checking for stalemate/victory
    private mutating func nextTurn() {
        let previousPlayer = activePlayer
        activePlayer = player(after: activePlayer)!
        
        if playerHasLegalMoves(activePlayer) == false {
            if importantPiecesThreatened(forPlayer: activePlayer, board: board) > 0 {
                // Checkmate
                gameState = .victory(previousPlayer)
            } else {
                // Stalemate
                gameState = .draw
            }
        }
    }
    
    // Moves a piece on the board, changing how the board is setup at the start of a game
    mutating func moveSetup(_ move: Move) {
        board.moveSetup(move: move)
    }
    
    private func player(after player: Player) -> Player? {
		if player == .black { return .white }
		else { return .black }
    }
	
	func legalMoves(for piece: Piece) -> [Position] {
		let legalMoves = board.squares.joined().map({ $0.position }).filter { isMoveLegal(Move(start: piece.position, end: $0)) }
		print(legalMoves)
		return legalMoves
	}
    
    // Returns the name of the piece with the given ID
    func piece(for pieceID: UUID) -> Piece? {
        return pieces.first { $0.id == pieceID }
    }
	
	private func isMoveLegal(_ move: Move?) -> Bool {
		guard let move = move, let boardAfterMove = board.boardState(after: move) else { return false }
		
		if importantPiecesThreatened(forPlayer: activePlayer, board: boardAfterMove) < 1 {
			return true
		} else {
			return false
		}
	}
	
	private func playerHasLegalMoves(_ player: Player) -> Bool {
		let pieces = board.pieces(for: player)
		
		for piece in pieces {
			if legalMoves(for: piece).count > 0 {
				return true
			}
		}
		
		return false
	}
	
	private func importantPiecesThreatened(forPlayer player: Player, board: Board) -> Int {
		guard let enemyPlayer = self.player(after: player) else { return 0 }
		
		let importantPiecePositions: [Position] = board.pieces(for: player).filter({ $0.isImportant }).map { $0.position }
		let enemyPieces: [Piece] = board.pieces(for: enemyPlayer)
		
		var numberOfImportantPiecesThreatened = 0
		
		for position in importantPiecePositions {
			pieceLoop: for piece in enemyPieces {
				if piece.canMove(to: position, in: board) {
					numberOfImportantPiecesThreatened += 1
					break pieceLoop
				}
			}
		}
		
		return numberOfImportantPiecesThreatened
	}
    
    func piece(_ id: String) -> Piece? {
        return pieces.first(where: { $0.id.uuidString == id })
    }
    
    // Convenience
    private func piece(_ id: UUID) -> Piece? { piece(id.uuidString) }
	
	init(board: Board, pieces: [Piece], players: [Player], name: String) {
		self.name = name
		self.board = board
		self.players = players
		self.pieces = pieces
		self.activePlayer = players.first! // You should not be able to create a board with less than one player
		self.gameState = .onGoing
		self.id = UUID()
	}
	
	init?(gameModel: GameModel) {
		
//		guard let testName = gameModel.name else { print("gameModel.name"); return nil }
//		guard let testBoardModel = gameModel.board else { print("boardModel"); return nil } // This is the issue, gameModel.board is nil
//		guard let testBoard = Board(boardModel: testBoardModel) else { print("board"); return nil }
//		guard let testPlayerModels = gameModel.players?.array as? [PlayerModel] else { print("playerModels"); return nil }
//		guard let testPieceModels = gameModel.pieces?.allObjects as? [PieceModel] else { print("pieceModels"); return nil }
//		guard let testID = gameModel.id else { print("id"); return nil }
		
		guard
			let name = gameModel.name,
			let boardModel = gameModel.board, let board = Board(boardModel: boardModel),
			let playerModels = gameModel.players?.array as? [PlayerModel],
			let pieceModels = gameModel.pieces?.array as? [PieceModel],
			let id = gameModel.id
		else {
			print("Failed to initialize game out of gameModel")
			return nil
		}
		
		// Crash when this fails just to alert me of the issue
		self.name = name
		self.board = board
		self.players = playerModels.compactMap { Player(rawValue: Int($0.player)) }
		
		self.pieces = pieceModels.compactMap { Piece(pieceModel: $0) }
		
		self.activePlayer = players.first!
		self.gameState = .onGoing
		self.id = id
		
		self.setupBoard()
	}
	
	static func standard() -> Game {
		let standardPieces = Board.standardPieces()
		let ids = Board.pieceIDs(pieces: standardPieces)
		let board = Board.standard(ids: ids)
		
		let pieces = standardPieces.map { $0.value }
		
		return Game(board: board, pieces: pieces, players: [.white, .black], name: "")
	}
	
	// Uses pieces to make the board return to the starting position
	private mutating func setupBoard() {
		board.setup(pieces: self.pieces)
	}
}

extension Game: Equatable {
	static func == (lhs: Game, rhs: Game) -> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.board != rhs.board { return false }
		if lhs.pieces != rhs.pieces { return false }
		if lhs.players != rhs.players { return false }
		
		// Not testing for activePlayer and gameState because these have to do with an active game. May change mind later.
		
		return true
	}
}

extension GameModel {
    var gameStruct: Game? { Game(gameModel: self) }
    var ranks: Int { gameStruct?.ranks ?? 0 }
    var files: Int { gameStruct?.files ?? 0 }
}
