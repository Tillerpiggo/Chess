//
//  MoverModel.swift
//  Chess
//
//  Created by Tyler Gee on 8/27/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import Foundation

extension MoverModel {
	func addOrRemovePattern(_ pattern: PatternModel?, index: Int?, remove: Bool) {
		if let index = index, remove {
			removeFromCanMovePatterns(at: index)
		} else if let pattern = pattern {
			print("Adding pattern: \(Pattern(patternModel: pattern)?.string)")
			addToCanMovePatterns(pattern)
		}
	}
}
