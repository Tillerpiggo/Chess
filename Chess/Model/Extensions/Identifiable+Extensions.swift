//
//  Array+Identifiable.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

import Foundation

extension Collection where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for (index, element) in self.enumerated() {
            if matching.id == element.id {
                return index
            }
        }
        
        return nil
    }
}

extension Array where Element == Piece {
	mutating func indexOfPiece(matching: Piece) -> Int? {
		for (index, piece) in self.enumerated() {
			if piece.id == piece.id {
				return index
			}
		}
		
		return nil
	}
}

extension Array where Element == [Square] {
    
	subscript(index: Position) -> Square? {
		get {
			guard index.file >= 0 && index.file < self.count, index.rank >= 0 && index.rank < self[index.file].count else {
				return nil
			}
			
			return self[index.file][index.rank]
		}
		
		set {
			if let newValue = newValue {
				self[index.file][index.rank] = newValue
			}
		}
	}
}
