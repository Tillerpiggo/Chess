//
//  AddBoardViewModel.swift
//  Chess
//
//  Created by Tyler Gee on 8/3/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI


class EditGameViewModel: ObservableObject {
	@Published var name: String {
		didSet { game.name = name; update() }
	}
	
	@Published var canSaveBoard: Bool = false
	@Published var hasChanged: Bool = false
	
	private(set) var game: Game
	private var initialGame: Game
	
	func update() {
		
		// Update hasChanged
		hasChanged = (game != initialGame)
		
		// Update canAddBoard
		canSaveBoard = !game.name.isEmpty && hasChanged
	}
	
	init(game: Game) {
		self.game = game
		self.initialGame = game
		
		self.name = game.name
	}
	
}

/*
class EditGameViewModel: ObservableObject {
	@Published var name: String {
		didSet { game.name = name; update() }
	}
	
	@Published var canSaveBoard: Bool = false
	@Published var hasChanged: Bool = false
	
	//private(set) var game: Game
	//private var initialGame: Game
	
	func update() {
		// Update canAddBoard
		// TODO: - Add check that this name is unique
		canSaveBoard = !game.name.isEmpty
		
		// Update hasChanged
		hasChanged = (game != initialGame)
	}
	
	// This is only a binding as a workaround
	init(game: Game) {
		self.game = game
		self.initialGame = game
		
		self.name = game.name
	}
	
}
*/
