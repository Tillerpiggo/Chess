//
//  GameCoreDataManager.swift
//  Chess
//
//  Created by Tyler Gee on 8/4/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

// Acts as a core data model
class GameCoreDataManager: NSObject, ObservableObject {
	private(set) var games = CurrentValueSubject<[GameModel], Never>([])
	
	private let gameFetchController: NSFetchedResultsController<GameModel>
	private let persistenceController: PersistenceController
	private let context: NSManagedObjectContext
	
	init(persistenceController: PersistenceController) {
		self.persistenceController = persistenceController
		self.context = persistenceController.container.viewContext
		let fetchRequest: NSFetchRequest<GameModel> = GameModel.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		
		gameFetchController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil, cacheName: nil
		)
		
		super.init()
		
		gameFetchController.delegate = self
		
		do {
			try gameFetchController.performFetch()
			games.value = gameFetchController.fetchedObjects ?? []
		} catch {
			NSLog("Error: could not fetch objects")
		}
	}
	
	// MARK: Interface - Adding, Removing, Editing
	
	func addGame(_ game: Game) {
		let _ = gameModel(from: game)
		persistenceController.save()
	}
	
	func addGames(_ games: [Game]) {
		for game in games {
			let _ = gameModel(from: game)
		}
		persistenceController.save()
	}
	
	func addPiece(_ piece: Piece, to game: Game) {
		if let gameModel = gameModel(game) {
			gameModel.addToPieces(pieceModel(from: piece))
			persistenceController.save()
		}
	}
	
	func removePiece(_ piece: Piece, from game: Game) {
		//deleteGame(game)
		renamePiece(piece, to: "REEEEE", in: game)
		persistenceController.save()
//		if let gameModel = gameModel(game), let pieceModel = pieceModel(piece, from: game) {
//			gameModel.removeFromPieces(pieceModel)
//			persistenceController.save()
//		}
	}
	
	// Moves the piece to a certain position in the pieces array
	func movePiece(_ piece: Piece, in game: Game, to position: Int) {
		if let gameModel = gameModel(game), let pieceModel = pieceModel(piece, from: game) {
			gameModel.removeFromPieces(pieceModel)
			gameModel.insertIntoPieces(pieceModel, at: position)
		}
		
		persistenceController.save()
	}
	
	func movePiece(from source: Int, to destination: Int, in game: Game) {
		if let gameModel = gameModel(game), let pieceModel = gameModel.pieces?.object(at: source) as? PieceModel {
			gameModel.removeFromPieces(at: source)
			
			
			// If the piece is moving from start -> end, the insertion index will be lower than what it was
			if source < destination {
				gameModel.insertIntoPieces(pieceModel, at: destination - 1)
				
			// If the piece is moving from the end -> start, it doesn't affect insertion index
			} else {
				gameModel.insertIntoPieces(pieceModel, at: destination)
			}
			
			persistenceController.save()
		}
	}
	
	func renamePiece(_ piece: Piece, to name: String, in game: Game) {
		if let pieceModel = pieceModel(piece, from: game) {
			pieceModel.name = name
			persistenceController.save()
		}
	}
	
	// TODO: implement stuff so it works for modifying Captures patterns as well
	func addOrRemovePattern(_ pattern: Pattern?, index: Int?, piece: Piece, game: Game, movementType: Piece.MovementType, remove: Bool) {
//		removePiece(piece, from: game)
//		persistenceController.save()
		//renamePiece(piece, to: "REEEEE", in: game)
		//persistenceController.save()
		if let pieceModel = pieceModel(piece, from: game)
		{
			
			var patternModel: PatternModel? = nil
			if let pattern = pattern { patternModel = self.patternModel(from: pattern) }
			
			// To prevent DRY:
			let addOrRemovePatternToFirstMove = {
				pieceModel.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				
				if piece.isCapturesSameAsNormal {
					//pieceModel.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				}
			}
			
			switch movementType {
			case .normal:
				print("pieceModel patterns: \((pieceModel.mover!.canMovePatterns!.array as! [PatternModel]).compactMap { Pattern(patternModel: $0)?.string })")
				
				pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				
				
				if piece.isCapturesSameAsNormal {
					//pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				}
				
				if piece.isFirstMoveSameAsNormal {
					addOrRemovePatternToFirstMove()
				}
			case .firstMove:
				addOrRemovePatternToFirstMove()
			case .captures:
				pieceModel.mover?.addOrRemovePattern(patternModel, index: index, remove: remove)
				pieceModel.firstMoveMover?.addOrRemovePattern(patternModel, index: index, remove: remove)
			}
			
			persistenceController.save()
			
			print("pieceModel patterns after: \((pieceModel.mover!.canMovePatterns!.array as! [PatternModel]).compactMap { Pattern(patternModel: $0)?.string })")
		}
	}
	
	func updateGame(_ game: Game) {
		if let gameModel = gameModel(game) {
			gameModel.name = game.name
			gameModel.board = boardModel(from: game.board)
			gameModel.players = playerModelSet(from: game.players)
		}
		
		persistenceController.save()
	}
	
	func deleteGame(_ game: Game) {
		if let gameModel = gameModel(game) {
			context.delete(gameModel)
		}
		
		persistenceController.save()
	}
	
	/// Retrieves an existing gameModel that matches a game
	private func gameModel(_ game: Game) -> GameModel? {
		return games.value.first(where: { $0.id == game.id })
	}
	
	/// Retrieves an existing pieceModel that matches a piece
	private func pieceModel(_ piece: Piece, from gameModel: GameModel) -> PieceModel? {
		let pieces = gameModel.pieces?.array as? [PieceModel]
		return pieces?.first(where: { $0.id == piece.id })
	}
	
	/// Retrieves an existing pieceModel that matches a piece
	private func pieceModel(_ piece: Piece, from game: Game) -> PieceModel? {
		if let gameModel = gameModel(game) {
			return pieceModel(piece, from: gameModel)
		} else {
			return nil
		}
	}
	
	/// Retrieves an existing patternModel that matches a pattern
	private func patternModel(in pieceModel: PieceModel, at index: Int, movementType: Piece.MovementType) -> PatternModel? {
		
		let patternSet: [Any]?
		switch movementType {
		case .normal: patternSet = pieceModel.mover?.canMovePatterns?.array
		case .firstMove: patternSet = pieceModel.firstMoveMover?.canMovePatterns?.array
		case .captures: patternSet = pieceModel.mover?.canCapturePatterns?.array
		}
		
		guard let patternModels = patternSet as? [PatternModel], index < patternModels.count else { return nil }
		
		return patternModels[index]
	}
	
	/*
	private func patternModel(_ pattern: Pattern, in pieceModel: PieceModel, movementType: Piece.MovementType) -> PatternModel? {
		var patternSet: NSOrderedSet?
		
		switch movementType {
		case .normal: patternSet = pieceModel.mover?.canMovePatterns
		case .firstMove: patternSet = pieceModel.firstMoveMover?.canMovePatterns
		case .captures: patternSet = pieceModel.mover?.canCapturePatterns
		}
		
		if let patterns = patternSet?.array as? [PatternModel] {
			if let pattern =
		}
	}
*/
	
	// MARK:  Model-CoreData translation functions
	
	/// Creates a new GameModel from a Game
	private func gameModel(from game: Game) -> GameModel {

		let gameModel = GameModel(context: context)
		
		gameModel.name = game.name
		gameModel.id = game.id
		gameModel.players = playerModelSet(from: game.players)
		gameModel.pieces = pieceModelSet(from: game.pieces)
		gameModel.board = boardModel(from: game.board)
		
		return gameModel
	}
	
	/// Creates a new boardModel from a Board
	private func boardModel(from board: Board) -> BoardModel {
		let boardModel = BoardModel(context: context)
		
		boardModel.squares = squareModelSet(from: board.squares)
		
		return boardModel
	}
	
	/// Creates a new NSOrderedSet of squares from a 2D array of Squares
	private func squareModelSet(from squares: [[Square]]) -> NSSet {
		return NSSet(array: squares.flatMap { $0 }.map { squareModel(from: $0) })
	}
	
	/// Creates a new NSOrderedSet of players from [Player]
	private func playerModelSet(from players: [Player]) -> NSOrderedSet {
		return NSOrderedSet(array: players.map { playerModel(from: $0) })
	}
	
	/// Creates a new NSOrderedSet of pieces from [Piece]
	private func pieceModelSet(from pieces: [Piece]) -> NSOrderedSet {
		return NSOrderedSet(array: pieces.map { pieceModel(from: $0) })
	}
	
	// Creates a new square model from a square object
	private func squareModel(from square: Square) -> SquareModel {
		
		let squareModel = SquareModel(context: context)
		
		squareModel.state = Int16(square.state.rawValue)
		squareModel.type = Int16(square.type.rawValue)
		squareModel.position = positionModel(from: square.position)
		squareModel.startingPieceID = square.startingPieceID
		if let owner = square.startingPieceOwner {
			squareModel.startingPieceOwner = playerModel(from: owner)
		}
		if let piece = square.piece {
			squareModel.piece = pieceModel(from: piece)
		}
		
		return squareModel
	}
	
	/// Creates a new position model from a position object
	private func positionModel(from position: Position) -> PositionModel {
		
		let positionModel = PositionModel(context: context)
		
		positionModel.rank = Int64(position.rank)
		positionModel.file = Int64(position.file)
		
		return positionModel
	}
	
	/// Creates a new pieceModel from a piece object
	private func pieceModel(from piece: Piece) -> PieceModel {
		
		let pieceModel = PieceModel(context: context)
		
		pieceModel.name = piece.name
		pieceModel.hasMoved = piece.hasMoved
		pieceModel.isImportant = piece.isImportant
		pieceModel.id = piece.id
		pieceModel.position = positionModel(from: piece.position)
		pieceModel.pieceImage = Int16(piece.image.rawValue)
		pieceModel.owner = playerModel(from: piece.owner)
		pieceModel.mover = moverModel(from: piece.mover)
		pieceModel.firstMoveMover = moverModel(from: piece.firstMoveMover)
		
		if pieceModel.mover == nil {
			print("pieceModel.mover is nil")
		}
		
		if pieceModel.firstMoveMover == nil {
			print("pieceModel.firstMoveMover is nil")
		}
		
		return pieceModel
	}
	
	private func playerModel(from player: Player) -> PlayerModel {
		
		let playerModel = PlayerModel(context: context)
		
		playerModel.player = Int16(player.rawValue)
		
		return playerModel
	}
	
	private func moverModel(from mover: Mover) -> MoverModel {
		
		let moverModel = MoverModel(context: context)
		
		moverModel.canMovePatterns = patternModelSet(from: mover.canMovePatterns)
		moverModel.canCapturePatterns = patternModelSet(from: mover.canCapturePatterns)
		
		return moverModel
		
	}
	
	private func patternModelSet(from patterns: [Pattern]) -> NSOrderedSet {
		return NSOrderedSet(array: patterns.map { patternModel(from: $0) })
	}
	
	private func patternModel(from pattern: Pattern) -> PatternModel {
		
		let patternModel = PatternModel(context: context)
		
		patternModel.type = Int16(pattern.type.rawValue)
		patternModel.custom = positionModelSet(from: pattern.custom)
		patternModel.isRestricting = pattern.isRestricting
		
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
	
	private func positionModelSet(from positions: [Position]) -> NSSet {
		return NSSet(array: positions.map { positionModel(from: $0) })
	}
	
	
	
}

extension GameCoreDataManager: NSFetchedResultsControllerDelegate {
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		// This makes adding Games approximately 30-40% slower
		// (But is obviously necessary)
		guard let games = controller.fetchedObjects as? [GameModel] else { return }

		print("Context has changed, reloading courses")
		self.games.value = games
	}
}


