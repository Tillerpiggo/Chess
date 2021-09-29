//
//  ChessTests.swift
//  ChessTests
//
//  Created by Tyler Gee on 8/4/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import XCTest

@testable import Chess

class ChessTests: XCTestCase {
	
	var testGameCoreDataManager: GameCoreDataManager!

    override func setUpWithError() throws {
		let testPersistenceController = PersistenceController(inMemory: true)
		testGameCoreDataManager = GameCoreDataManager(persistenceController: testPersistenceController)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	/*
	func testBoardEquality() throws {
		let board = Board.standard
		let otherBoard = Board.standard
		XCTAssert(board == otherBoard)
	}
*/
	
	func testMoverCombination() throws {
		print("1")
		let mover = Mover.knight.appendingPatterns([Pattern(.pawn)])
		print("2")
		XCTAssert(mover.canMovePatterns == [Pattern(.knight), Pattern(.pawn)])
	}
	
	func testMoverEquality() throws {
		let mover = Mover.queen.appendingPatterns([Pattern(.bishop)])
		let otherMover = Mover.queen.appendingPatterns([Pattern(.bishop)])
		let thirdMover = Mover.queen.appendingPatterns([Pattern(.bishop), Pattern(.king)])
		
		XCTAssert(mover == otherMover)
		XCTAssert(mover != thirdMover)
	}
	
	func testSquareConversionToCoreData() throws {
		let position = Position(rank: 3, file: 2)
		
		let pawn = Piece.pawn(position: position, owner: .black)
		let square = Square(state: .occupied, piece: pawn, startingPieceID: pawn.id, position: position, type: .dark)
		let otherSquare = Square(state: .occupied, piece: pawn, startingPieceID: pawn.id, position: position, type: .dark)
		
		// The ID should be the same, so they should actually be the same
		XCTAssert(square == otherSquare)
	}
	
	// Tests if a game can properly be converted into core data and back again without issue
    func testGameConversionToCoreData() throws {
		// Create and add a new game to core data
		
		let standardPieces = Board.standardPieces()
		var board = Board.standard(ids: Board.pieceIDs(pieces: standardPieces))
		
		// Test combining and restrictions
		let bishopKnight = Piece(
			name: "Bishop Knight",
			image: .bishop,
			mover: Mover.bishop.appendingPatterns([Pattern(.knight)]),
			position: Position(rank: 3, file: 3),
			owner: .white
		)
		
		let restrictedQueen = Piece(
			name: "Restricted Queen",
			image: .queen,
			mover: Mover.queen.appendingPatterns([Pattern(.outsideDistance, isRestricting: true, rankDistance: 2, fileDistance: 2)]),
			position: Position(rank: 4, file: 4),
			owner: .white
		)
		
		board.squares[3][3].setPiece(bishopKnight)
		board.squares[4][4].setPiece(restrictedQueen)
		
		
		let pieces = standardPieces.map { $0.value }
		
		//print("board: \(board.squares.flatMap { $0 }.map { $0.piece?.mover.canMovePatterns.map { $0.type } })")
		
		let game = Game(board: board, pieces: pieces, players: [.white, .black], name: "Test Board")
		
		//let board = Board(squares: [[Square(state: .occupied, piece: .pawn(position: Position(rank: 0, file: 0), owner: .white), position: Position(rank: 0, file: 0), type: .dark)]])
		//let game = Game(board: board, players: [.white, .black], name: "Test Board")
		let gameStore = GameManager(gameManager: testGameCoreDataManager)
		gameStore.addGame(game)
		
		// Test that it can be converetd from a gameModel back into a game
		let optionalConvertedGame = Game(gameModel: testGameCoreDataManager.games.value.first!)
		XCTAssert(optionalConvertedGame != nil)
		
		let convertedGame = optionalConvertedGame!
		
		// Test that it is still the same
		XCTAssert(game.name == convertedGame.name)
		print("game.board: \(game.board.squares.flatMap { $0 }.map { $0.piece?.mover.canMovePatterns.map { $0.type } })")
		print("convertedGame.board: \(convertedGame.board.squares.flatMap { $0 }.map { $0.piece?.mover.canMovePatterns.map { $0.type } })")
		
		XCTAssert(game.board == convertedGame.board, "While converting game to gameModel, failed to properly convert board.")
		XCTAssert(game.id == convertedGame.id)
		print("Players: \(game.players)")
		print("ConvertedPlayers: \(convertedGame.players)")
		XCTAssert(game.players == convertedGame.players)
		
		// Remove the game
		
    }
	
	
	func assertGamesAreEqual(game1: Game, game2: Game) throws {
		XCTAssert(game1.name == game2.name)
		XCTAssert(game1.board == game2.board, "While converting game to gameModel, failed to properly convert board.")
		XCTAssert(game1.id == game2.id)
		print("Players: \(game1.players)")
		print("ConvertedPlayers: \(game2.players)")
		XCTAssert(game1.players == game2.players)
	}

	
	func testUpdateGame() throws {
		// Create a new game
		let standardPieces = Board.standardPieces()
		let board = Board.standard(ids: Board.pieceIDs(pieces: standardPieces))
		
		let pieces = standardPieces.map { $0.value }
		
		var game = Game(board: board, pieces: pieces, players: [.white, .black], name: "Test Updating")
		
		let gameCopy = game
		
		// Save it to core data
		let gameStore = GameManager(gameManager: testGameCoreDataManager)
		gameStore.addGame(game)
		
		// Change the game
		game.name = "Test Updating Changed"
		game.board = Board.empty()
		game.players = [.black, .white]
		
		// Update it
		gameStore.updateGame(game)
		
		// Retrieve the game
		if let gameModel = testGameCoreDataManager.games.value.first(where: { $0.id == game.id }) {
			// Check that the game properly updated
			let updatedGame = Game(gameModel: gameModel)!
			try assertGamesAreEqual(game1: game, game2: updatedGame)
			
			// Check that the game was properly changed from the original start
			XCTAssert(gameCopy.name != updatedGame.name)
			XCTAssert(gameCopy.board != updatedGame.board)
			XCTAssert(gameCopy.players != updatedGame.players)
			XCTAssert(gameCopy.id == updatedGame.id)
		} else {
			XCTAssert(false, "Failed to relocate a game after saving it to core data")
		}
	}
	
	func testRemovePattern() {
		var game = Game.standard()
		
		let gameStore = GameManager(gameManager: testGameCoreDataManager)
		gameStore.addGame(game)
		
		let firstPiece = game.pieces.first!
		let secondPiece = game.pieces[1]
		
		let pattern = Pattern(.forwardSlash)
		gameStore.removePattern(at: IndexSet(integer: 0), piece: secondPiece, game: game, movementType: .normal)
		gameStore.addPattern(pattern, to: firstPiece, in: game, movementType: .normal)
		gameStore.addPattern(pattern, to: firstPiece, in: game, movementType: .normal)
		
		if let gameModel = testGameCoreDataManager.games.value.first(where: { $0.id == game.id }) {
			let game = Game(gameModel: gameModel)!
			
			//print("pieceIDs: \(game.pieces.map { $0.id })")
			//print("modifiedPieceID: \(firstPiece.id), removedPieceID: \(secondPiece.id)")
			if let modifiedPiece = game.pieces.first(where: { $0.id == firstPiece.id }) {
				print("firstPiece: \(firstPiece.name), patterns: \(firstPiece.mover.canMovePatterns.map { $0.string })")
				print("modifiedPiece: \(modifiedPiece.name), patterns: \(modifiedPiece.mover.canMovePatterns.map { $0.string })")
				XCTAssert(modifiedPiece.mover != firstPiece.mover)
				XCTAssert(modifiedPiece.mover.canMovePatterns.last! == pattern)
			}
			
			if let removedPiece = game.pieces.first(where: { $0.id == secondPiece.id }) {
				print("secondPiece: \(secondPiece.name), patterns: \(secondPiece.mover.canMovePatterns.map { $0.string })")
				print("removedPiece: \(removedPiece.name), patterns: \(removedPiece.mover.canMovePatterns.map { $0.string })")
				print("removedCount: \(removedPiece.mover.canMovePatterns.count), secondCount: \(secondPiece.mover.canMovePatterns.count)")
				XCTAssert(removedPiece.mover.canMovePatterns.count == secondPiece.mover.canMovePatterns.count - 1)
			}
		}
	}
	
	/*
	func testPerformance() throws {
		let gameStore = GameStore(gameManager: testGameCoreDataManager)
		var games = [Game]()
		
		// Add 50 games and convert them all back into Games
		// Together, this takes 1.221s (not sure why)
		measure {
			
			// Alone, this for loop takes 0.001s
			let standardBoard = Board.standard
			for index in 0..<50 {
				let game = Game(
					board: standardBoard,
					players: [.white, .black],
					name: "Performance Test \(index)")
				games.append(game)
			}
			
			// Alone, this takes 0.221s
			
			// When the games have 1 square boards, though, it takes about 0.001s/game
			let calculateGames = games
			gameStore.addGames(games)
			
			let _ = gameStore.games
		}
		
		// It seems like the biggest changeable slowdown comes from
		// initializing each square as a new SquareModel
		// (since there are like 64 squares)
	}
*/
	
}
