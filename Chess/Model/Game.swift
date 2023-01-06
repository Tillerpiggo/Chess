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
    var description: String
    var board: Board
    var setupPosition: SetupPosition
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
        setupPosition.applyMove(move, inBoard: board)
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
		guard let move = move, let boardAfterMove = board.afterMove(move) else { return false }
		
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
	
    init(board: Board, pieces: [Piece], players: [Player], name: String, description: String) {
		self.name = name
        self.description = description
		self.board = board
        self.setupPosition = SetupPosition()
		self.players = players
		self.pieces = pieces
		self.activePlayer = players.first! // You should not be able to create a board with less than one player
		self.gameState = .onGoing
		self.id = UUID()
	}
	
	init?(gameModel: GameModel) {
		guard
			let name = gameModel.name,
            let description = gameModel.gameDescription,
			let boardModel = gameModel.board, let board = Board(boardModel: boardModel),
            let setupPositionModel = gameModel.setupPosition, let setupPosition = SetupPosition(setupPositionModel: setupPositionModel),
			let playerModels = gameModel.players?.array as? [PlayerModel],
			let pieceModels = gameModel.pieces?.array as? [PieceModel],
			let id = gameModel.id
		else {
			print("Failed to initialize game out of gameModel")
			return nil
		}
		
		// Crash when this fails just to alert me of the issue
		self.name = name
        self.description = description
        self.setupPosition = setupPosition
		self.board = board
        self.setupPosition = setupPosition
		self.players = playerModels.compactMap { Player(rawValue: Int($0.player)) }
		
		self.pieces = pieceModels.compactMap { Piece(pieceModel: $0) }
		
		self.activePlayer = players.first!
		self.gameState = .onGoing
		self.id = id
		
		self.setupBoard()
	}
	
	// Uses pieces to make the board return to the starting position
	private mutating func setupBoard() {
        setupPosition.forEachPiece { (id, position, player) in
            if var archetypalPiece = pieces.first(where: { $0.id == id }) {
                archetypalPiece.owner = player
                board.setPiece(archetypalPiece, at: position)
            }
        }
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

// Contains definitions/helper methods for standard games and other common variants
extension Game {
    
//    enum StandardPieceType: Hashable {
//        case king, queen, bishop, knight, rook, whitePawn, blackPawn
//    }
    
    // Generates standard pieces
    static func standardPieces() -> [Game.StandardPieceType: Piece] {
        
        // The position of the piece. Since these pieces will be put in Game.pieces, their position on the board doesn't matter
        // However, the rank determines their position in the list.
        // This is just a fast way to get a position with a specific rank.
        let p: (Int) -> Position = { rank in Position(rank: rank, file: 0) }
        
        // The owner of the piece. All but the pawn can be either black or white
        let o: Player = .blackOrWhite
        
        var pieces: [Game.StandardPieceType: Piece] = [
            .whitePawn: .whitePawn(position: p(0)),
            .blackPawn: .blackPawn(position: p(0)),
            .knight: .knight(position: p(2), owner: o),
            .bishop: .bishop(position: p(3), owner: o),
            .rook: .rook(position: p(4), owner: o),
            .queen: .queen(position: p(5), owner: o),
            .king: .king(position: p(6), owner: o)
        ]
        
        
        // Set up promotion pieces for white and black
        let promotionPieceTypes: [Game.StandardPieceType] = [.knight, .bishop, .rook, .queen]
        let promotionPieces: [UUID] = promotionPieceTypes.compactMap { pieces[$0]?.id }
        
        var whitePawn = pieces[.whitePawn]!
        whitePawn.promotionPieces = promotionPieces
        pieces[.whitePawn] = whitePawn
        
        var blackPawn = pieces[.blackPawn]!
        blackPawn.promotionPieces = promotionPieces
        pieces[.blackPawn] = blackPawn
        
        return pieces
    }
    
    static func standardGame() -> Game {
        let pieces = standardPieces()
        var setupPosition = SetupPosition(
        
    }
    
    static func standard(ids: [Game.StandardPieceType: UUID]) -> Board {
        // Create an empty board
        var squares = Board.emptyBoard().squares
        
        // Add in the pieces
        let backRank: [Game.StandardPieceType] = [
            .rook,
            .knight,
            .bishop,
            .queen,
            .king,
            .bishop,
            .knight,
            .rook
        ]
        
        for (fileIndex, _) in squares.enumerated() {
            squares[fileIndex][0].setPiece(backRank[fileIndex], owner: .white, id: ids[backRank[fileIndex]]!)
            squares[fileIndex][1].setPiece(.whitePawn, owner: .white, id: ids[.whitePawn]!)
            squares[fileIndex][7].setPiece(backRank[fileIndex], owner: .black, id: ids[backRank[fileIndex]]!)
            squares[fileIndex][6].setPiece(.blackPawn, owner: .black, id: ids[.blackPawn]!)
        }
        
        return Board(squares: squares)
    }
    
}
