//
//  VisualEffectView.swift
//  Chess
//
//  Created by Tyler Gee on 9/11/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

// Use this until you switch to iOS 15
struct VisualEffectView: UIViewRepresentable {
	var effect: UIVisualEffect?
	func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
	func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
