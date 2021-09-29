//
//  NavigationAppearanceModifier.swift
//  Chess
//
//  Created by Tyler Gee on 8/14/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

// From https://www.youtube.com/watch?v=kCJyhG8zjvY

struct NavigationAppearanceModifier: ViewModifier {
	init(backgroundColor: UIColor, foregroundColor: UIColor, tintColor: UIColor?, hideSeperator: Bool) {
		let navBarAppearance = UINavigationBarAppearance()
		navBarAppearance.titleTextAttributes = [.foregroundColor: foregroundColor]
		navBarAppearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor]
		navBarAppearance.backgroundColor = backgroundColor
		if hideSeperator { navBarAppearance.shadowColor = .clear }
		
		UINavigationBar.appearance().standardAppearance = navBarAppearance
		UINavigationBar.appearance().compactAppearance = navBarAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
		
		if let tintColor = tintColor {
			UINavigationBar.appearance().tintColor = tintColor
		}
	}
	
	func body(content: Content) -> some View {
		content
	}
}

extension View {
	func navigationAppearance(backgroundColor: UIColor, foregroundColor: UIColor, tintColor: UIColor? = nil, hideSeparator: Bool = false) -> some View {
		self.modifier(NavigationAppearanceModifier(backgroundColor: backgroundColor, foregroundColor: foregroundColor, tintColor: tintColor, hideSeperator: hideSeparator))
	}
}
