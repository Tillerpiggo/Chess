//
//  Array+Extensions.swift
//  Chess
//
//  Created by Tyler Gee on 8/2/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import Foundation


extension Array {
	func splitIntoRows(ofLength rowLength: Int) -> [Array] {
		let rowCount = Int((Double(self.count) / Double(rowLength)).rounded(.up))
		
		var rowArray = [Array](repeating: Array(), count: rowCount)
		
		for (index, element) in self.enumerated() {
			let rowIndex = Int(Double(index) / Double(rowLength).rounded(.down))
			rowArray[rowIndex].append(element)
		}
		
		return rowArray
	}
	
	func appending(_ otherArray: [Element]) -> [Element] {
		var copy = self
		copy.append(contentsOf: otherArray)
		return copy
	}
}

extension Array where Element: RangeReplaceableCollection {
	var largestDimension: Int {
		let width = count
		let height = self.map { $0.count }.max() ?? 0
		
		return Swift.max(width, height)
	}
}

extension Array where Element == NSItemProvider {
	
	func loadObjects<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
		if let provider = self.first(where: { $0.canLoadObject(ofClass: theType) }) {
			provider.loadObject(ofClass: theType) { object, error in
				if let value = object as? T {
					DispatchQueue.main.async {
						load(value)
					}
				}
			}
			return true
		}
		return false
	}
	
	func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
		if let provider = self.first(where: { $0.canLoadObject(ofClass: theType) }) {
			let _ = provider.loadObject(ofClass: theType) { object, error in
				if let value = object {
					DispatchQueue.main.async {
						load(value)
					}
				}
			}
			return true
		}
		return false
	}
}
