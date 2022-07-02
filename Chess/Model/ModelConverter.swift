//
//  ModelConverter.swift
//  Chess
//
//  Created by Tyler Gee on 8/31/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

/// Converts structs into core data models and finds existing core data models from structs
struct ModelConverter {
	
	var context: NSManagedObjectContext
	var games: [GameModel]
	
	// MARK: - Create new models
	
	/// Creates a new GameModel from a Game
	func gameModel(from game: Game) -> GameModel {
        print("creating gamemodel from game")
		let gameModel = GameModel(context: context)
		
		gameModel.name = game.name
		gameModel.id = game.id
		gameModel.players = playerModelSet(from: game.players)
		gameModel.pieces = pieceModelSet(from: game.pieces, in: gameModel)
		gameModel.board = boardModel(from: game.board)
		
		return gameModel
	}
	
	/// Creates a new boardModel from a Board
	func boardModel(from board: Board) -> BoardModel {
		let boardModel = BoardModel(context: context)
		
		boardModel.squares = squareModelSet(from: board.squares)
		
		return boardModel
	}
	
	/// Creates a new NSOrderedSet of squares from a 2D array of Squares
	func squareModelSet(from squares: [[Square]]) -> NSSet {
		return NSSet(array: squares.flatMap { $0 }.map { squareModel(from: $0) })
	}
	
	/// Creates a new NSOrderedSet of players from [Player]
	func playerModelSet(from players: [Player]) -> NSOrderedSet {
		return NSOrderedSet(array: players.map { playerModel(from: $0) })
	}
	
	/// Creates a new NSOrderedSet of pieces from [Piece]
	func pieceModelSet(from pieces: [Piece], in game: GameModel) -> NSOrderedSet {
		return NSOrderedSet(array: pieces.sorted(by: { $0.position.rank < $1.position.rank }).map { pieceModel(from: $0, in: game) })
	}
	
	// Creates a new square model from a square object
	func squareModel(from square: Square) -> SquareModel {
		
		let squareModel = SquareModel(context: context)
		
		squareModel.state = Int16(square.state.rawValue)
		squareModel.type = Int16(square.type.rawValue)
		squareModel.position = positionModel(from: square.position)
		squareModel.startingPieceID = square.startingPieceID
		if let startingPieceOwner = square.startingPieceOwner { squareModel.startingPieceOwner = playerModel(from: startingPieceOwner) }
		
		// TODO: make sure this doesn't screw anything up
		/*
		if let piece = square.piece {
			squareModel.piece = pieceModel(from: piece)
		}
*/
		
		return squareModel
	}
	
	/// Creates a new position model from a position object
	func positionModel(from position: Position) -> PositionModel {
		
		let positionModel = PositionModel(context: context)
		
		positionModel.rank = Int64(position.rank)
		positionModel.file = Int64(position.file)
		
		return positionModel
	}
	
	/// Creates a new pieceModel from a piece object
	func pieceModel(from piece: Piece, in game: GameModel) -> PieceModel {
		
		let pieceModel = PieceModel(context: context)
		
		pieceModel.name = piece.name
		pieceModel.hasMoved = piece.hasMoved
		pieceModel.isImportant = piece.isImportant
		pieceModel.id = piece.id
		pieceModel.position = positionModel(from: piece.position)
		pieceModel.pieceImage = Int16(piece.image.rawValue)
        pieceModel.promotionZone = positionModelSet(from: piece.promotionZone)
        pieceModel.promotionPieces = piece.promotionPieces
		pieceModel.owner = playerModel(from: piece.owner)
		pieceModel.mover = moverModel(from: piece.mover, piece: pieceModel, firstMove: false)
		pieceModel.firstMoveMover = moverModel(from: piece.firstMoveMover, piece: pieceModel, firstMove: true)
		pieceModel.game = game
		
		if pieceModel.mover == nil {
			print("pieceModel.mover is nil")
		}
		
		if pieceModel.firstMoveMover == nil {
			print("pieceModel.firstMoveMover is nil")
		}
		
		return pieceModel
	}
	
	/// Creates a new PlayerModel from a Player
	func playerModel(from player: Player) -> PlayerModel {
		
		let playerModel = PlayerModel(context: context)
		
		playerModel.player = Int16(player.rawValue)
		
		return playerModel
	}
	
	/// Creates a new MoverModel from a Mover
	func moverModel(from mover: Mover, piece: PieceModel, firstMove: Bool) -> MoverModel {
		
		let moverModel = MoverModel(context: context)
		
		moverModel.canMovePatterns = patternModelSet(from: mover.canMovePatterns, mover: moverModel, captures: false)
		moverModel.canCapturePatterns = patternModelSet(from: mover.canCapturePatterns, mover: moverModel, captures: true)
		if firstMove {
			moverModel.pieceFirstMove = piece
		} else {
			moverModel.piece = piece
		}
		
		return moverModel
		
	}
    
    /// Creates a new NSOrderedSet from [Position]
    func positionModelSet(from positions: [Position]) -> NSOrderedSet {
        return NSOrderedSet(array: positions.map { positionModel(from: $0) })
    }
	
	/// Creates a new NSOrderedSet from [Pattern]
	func patternModelSet(from patterns: [Pattern], mover: MoverModel, captures: Bool) -> NSOrderedSet {
		return NSOrderedSet(array: patterns.map { patternModel(from: $0, mover: mover, captures: captures) })
	}
	
	/// Creates a new PatternModel from a pattern
	func patternModel(from pattern: Pattern, mover: MoverModel, captures: Bool) -> PatternModel {
		
		let patternModel = PatternModel(context: context)
		
		patternModel.type = Int16(pattern.type.rawValue)
		patternModel.custom = positionModelSet(from: pattern.custom)
		patternModel.isRestricting = pattern.isRestricting
		
		if captures {
			patternModel.moverCanCapture = mover
		} else {
			patternModel.moverCanMove = mover
		}
		
		switch pattern.type {
		case .withinDistance, .outsideDistance:
			patternModel.rankDistance = Int64(pattern.rankDistance ?? 0)
			patternModel.fileDistance = Int64(pattern.fileDistance ?? 0)
		case .inDirections:
			if let directions = pattern.directions {
				patternModel.directions = directions.map { NSNumber(value: $0.rawValue) }
			}
		default: break
		}
		
		return patternModel
	}
	
	/// Creates a new NSSet from [Position]
	func positionModelSet(from positions: [Position]) -> NSSet {
		return NSSet(array: positions.map { positionModel(from: $0) })
	}
	
	// MARK: - Retrieve Existing Models
	
	/// Retrieves an existing gameModel that matches a game
	func retrieveGameModel(_ game: Game) -> GameModel? {
		return games.first(where: { $0.id == game.id })
	}
	
	/// Retrieves an existing pieceModel that matches a piece
	func retrievePieceModel(_ piece: Piece, from game: GameModel) -> PieceModel? {
		let pieces = game.pieces?.array as? [PieceModel]
		return pieces?.first(where: { $0.id == piece.id })
	}
	
	/// Retrieves an existing patternModel that matches a pattern
	func retrievePatternModel(in pieceModel: PieceModel, at index: Int, movementType: Piece.MovementType) -> PatternModel? {
		
		let patternSet: [Any]?
		switch movementType {
		case .normal: patternSet = pieceModel.mover?.canMovePatterns?.array
		case .firstMove: patternSet = pieceModel.firstMoveMover?.canMovePatterns?.array
		case .captures: patternSet = pieceModel.mover?.canCapturePatterns?.array
		}
		
		guard let patternModels = patternSet as? [PatternModel], index < patternModels.count else { return nil }
		
		return patternModels[index]
	}
	
	init(context: NSManagedObjectContext, games: [GameModel]) {
		self.context = context
		self.games = games
	}
}
