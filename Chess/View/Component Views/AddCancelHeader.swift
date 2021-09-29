//
//  AddCancelHeader.swift
//  Chess
//
//  Created by Tyler Gee on 8/3/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

// View designed to be put at the top of forms, specifically those where you are adding an item. Shows a cancel button, add button, and title
struct AddCancelHeader: View {
	@Environment(\.colorScheme) var colorScheme
	
	var title: String
	var isAddEnabled: Bool
	
	var onCancel: () -> Void = { }
	var onAdd: () -> Void = { }
	var includeCancelButton: Bool = true
	var addButtonTitle = "Add"
	
	var body: some View {
		ZStack {
			// TODO - make this rectangle a blur effect because I think that looks cool
			Rectangle()
				.fill(Color.backgroundColor)
				.frame(height: 60)
			Group {
				if self.includeCancelButton {
					HStack {
						Button(action: { self.onCancel() }) {
							Text("Cancel")
								.foregroundColor(.boardGreen)
						}
						
						Spacer()
					}
				}
					
				Text(self.title)
					.fontWeight(.bold)
					
				HStack {
					Spacer()
					
					Button(action: { self.onAdd() }) {
						ZStack {
							// To animate color change (maybe somehow make this a view modifier later)
							Text(self.addButtonTitle)
								.fontWeight(.bold)
								.foregroundColor(colorScheme == .dark ? self.darkGray : self.gray)
							Text(self.addButtonTitle)
								.fontWeight(.bold)
								.foregroundColor(.boardGreen)
								.opacity(isAddEnabled ? 1 : 0)
								.animation(.easeInOut(duration: 0.1))
						}
					}
					.disabled(!isAddEnabled)
				}
			}
			.padding(.horizontal, 16)
		}
	}
	
	private let gray = Color(white: 0.9)
	private let darkGray = Color(white: 0.4)
}
