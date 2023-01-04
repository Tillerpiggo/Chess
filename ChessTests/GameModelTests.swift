//
//  GameModelTests.swift
//  ChessTests
//
//  Created by Tyler Gee on 1/2/23.
//  Copyright © 2023 Beaglepig. All rights reserved.
//

import XCTest

@testable import Chess

final class GameModelTests: XCTestCase {
    
    var mockCoreDataGameManager: CoreDataGameManager!

    // Create a mock persistence controller to allow testing saving to and retrieving from Core Data
    override func setUpWithError() throws {
        let mockPersistenceController = PersistenceController(inMemory: true)
        let mockGameManager = ModelManager<GameModel>(persistenceController: mockPersistenceController, sortDescriptors: [])
        mockCoreDataGameManager = CoreDataGameManager(gameManager: mockGameManager)
    }

    // Erases the controller and resets (deletes) all the data
    // so each individual method starts with a blank core data
    override func tearDownWithError() throws {
        mockCoreDataGameManager.deleteAllGames()
        mockCoreDataGameManager = nil
    }
    
    // Tests to check that a game is being properly saved to and retrieved from core data
    // (so all properties are retained at depth)
    
    // See that a standard game of chess is properly saved
    func testSavingStandardGame() {
        
    }
    
    // Tests checking equality between games
    
    

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension CoreDataGameManager {
    
    // This should only be called for testing since we don't want to accidentally wipe out a user's data
    func deleteAllGames() {
        for game in games {
            deleteGame(game)
        }
    }
}
