//
//  Player.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation

/*
struct Player: Identifiable, Equatable {
    var id: UUID = UUID()
    
    
}
*/

// Might add stuff like red, blue, green, and yellow for 4-player
// blackOrWhite means either black or white (for archetype pieces)
enum Player: Int, Equatable {
	case white = 0, black = 1, blackOrWhite = 2
	
	var string: String {
		switch self {
		case .black: return "Black"
		case .white: return "White"
        default: return "Implement/fix this; see enum Player"
		}
	}
}
