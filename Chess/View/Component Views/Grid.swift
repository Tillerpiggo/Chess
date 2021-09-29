//
//  Grid.swift
//  Chess
//
//  Created by Tyler Gee on 8/2/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct Grid<Content: View>: View {
	let numberOfItems: Int
	let columns: Int
	let rowSpacing: CGFloat
	let columnSpacing: CGFloat
	let content: (Int) -> Content
	
	var body: some View {
		let rows = (Double(self.numberOfItems) / Double(self.columns)).rounded(.up)
		
		GeometryReader { geometry in
			let totalColumnSpacing = CGFloat(self.columns - 1) * self.columnSpacing
			let columnWidth = (geometry.size.width - totalColumnSpacing) / CGFloat(self.columns)
			
			LazyVStack {
				ForEach(0..<Int(rows)) { row in
					Spacer(minLength: self.rowSpacing)
					HStack(spacing: self.columnSpacing) {
						ForEach(0..<self.columns) { column in
							let index = row * self.columns + column
							
							if index < self.numberOfItems {
								self.content(index).frame(width: columnWidth)
							} else {
								Spacer().frame(width: columnWidth)
							}
						}
					}
				}
			}
		}
	}
}
