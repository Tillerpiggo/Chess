//
//  String+Extensions.swift
//  Chess
//
//  Created by Tyler Gee on 8/27/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import Foundation

extension String {
	func removingLast(_ k: Int) -> String {
		var newString = self
		newString.removeLast(2)
		return newString
	}
}
