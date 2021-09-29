//
//  ConfirmDismissActionSheet.swift
//  Chess
//
//  Created by Tyler Gee on 8/14/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct ConfirmDismissActionSheet: ViewModifier {
	
	@Binding var isPresented: Bool
	@Binding var isModalViewPresented: Bool
	
	func body(content: Content) -> some View {
		content
		.actionSheet(isPresented: $isPresented) {
			ActionSheet(
				title: Text("Are you sure you want to discard changes?"),
				buttons: [
					.destructive(Text("Discard Changes")) {
						isModalViewPresented = false
					},
					.cancel(Text("Continue Editing")) {
						// do nothing, just continue
					},
				]
			)
		}
	}
}

extension View {
	func confirmDismissActionSheet(isPresented: Binding<Bool>, isModalViewPresented: Binding<Bool>) -> some View {
		return self.modifier(ConfirmDismissActionSheet(isPresented: isPresented, isModalViewPresented: isModalViewPresented))
	}
}
