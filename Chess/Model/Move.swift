//
//  Move.swift
//  Chess
//
//  Created by Tyler Gee on 2/7/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import Foundation

struct Move: Hashable {
	var start: Position
	var end: Position
	
	var horizontalDistance: Int { abs(horizontalDistanceSigned) }
	var verticalDistance: Int { abs(verticalDistanceSigned) }
	
	var horizontalDistanceSigned: Int { end.file - start.file }
	var verticalDistanceSigned: Int { end.rank - start.rank }
	
	var directions: [Direction] {
		var directions = [Direction]()
		
		if start.file > end.file {
			directions.append(.left)
		} else if start.file < end.file {
			directions.append(.right)
		}
		
		if start.rank > end.rank {
			directions.append(.down)
		} else if start.rank < end.rank {
			directions.append(.up)
		}
		
		return directions
	}
	
	init?(start: Position, end: Position) {
		// Make sure the move is actually a move
		if start != end {
			self.start = start
			self.end = end
		} else {
			return nil
		}
	}
	
	enum Direction: Int, Hashable {
		case up = 0, down, left, right
		
		var string: String {
			switch self {
			case .up: return "Up"
			case .down: return "Down"
			case .left: return "Left"
			case .right: return "Right"
			}
		}
		
		static var directions: [Move.Direction] = [.up, .down, .left, right]
	}
}
