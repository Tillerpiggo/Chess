//
//  Position.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation

struct Position: Equatable, Hashable {
    var rank: Int
    var file: Int
    
    static func == (lhs: Position, rhs: Position) -> Bool {
        return (lhs.rank == rhs.rank) && (lhs.file == rhs.file)
    }
	
	func offset(ranks: Int, files: Int) -> Position {
		return Position(rank: self.rank + ranks, file: self.file + files)
	}
	
	init(rank: Int, file: Int) {
		self.rank = rank
		self.file = file
	}
	
	init?(positionModel: PositionModel) {
		self.init(rank: Int(positionModel.rank), file: Int(positionModel.file))
	}
}
