//
//  ModalView.swift
//  Chess
//
//  Created by Tyler Gee on 8/3/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

// This allows the use of the presentation(isModal:) modifier that can stop a modal view from being dragged down to dismiss.
// Taken from https://stackoverflow.com/questions/56615408/prevent-dismissal-of-modal-view-controller-in-swiftui/61239704#61239704

// updateUIViewController isn't called for some reason by @ObservedObject changes in the contained view
struct ModalView<T: View>: UIViewControllerRepresentable {
	let view: T
	var isModal: Bool
	let onDismissalAttempt: (()->())?
	
	func makeUIViewController(context: Context) -> UIHostingController<T> {
		UIHostingController(rootView: view)
	}
	
	func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
		uiViewController.parent?.presentationController?.delegate = context.coordinator
		context.coordinator.modalView = self
		uiViewController.rootView = view
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
		var modalView: ModalView
		
		init(_ modalView: ModalView) {
			self.modalView = modalView
		}
		
		func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
			!modalView.isModal
		}
		
		func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
			modalView.onDismissalAttempt?()
		}
	}
	
	init(view: T, isModal: Bool, onDismissalAttempt: (()->())?) {
		self.view = view
		self.isModal = isModal
		self.onDismissalAttempt = onDismissalAttempt
	}
}

extension View {
	func presentation(isModal: Bool, onDismissalAttempt: (()->())? = nil) -> some View
	{
		ModalView(view: self, isModal: isModal, onDismissalAttempt: onDismissalAttempt)
	}
}
