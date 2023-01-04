//
//  AutofocusTextField.swift
//  Chess
//
//  Created by Tyler Gee on 8/14/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct AutofocusTextField: UIViewRepresentable {

	class Coordinator: NSObject, UITextFieldDelegate {

		@Binding var text: String
		var placeholder: String?
		
		var didBecomeFirstResponder = false

		init(_ placeholder: String?, text: Binding<String>) {
			self.placeholder = placeholder
			_text = text
		}

		func textFieldDidChangeSelection(_ textField: UITextField) {
			text = textField.text ?? ""
		}

	}

	var placeholder: String?
	@Binding var text: String
	var isFirstResponder: Bool = false

	func makeUIView(context: UIViewRepresentableContext<AutofocusTextField>) -> UITextField {
		let textField = UITextField(frame: .zero)
		textField.delegate = context.coordinator
		textField.placeholder = placeholder
		return textField
	}

	func makeCoordinator() -> AutofocusTextField.Coordinator {
		return Coordinator(placeholder, text: $text)
	}

	func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<AutofocusTextField>) {
		uiView.text = text
		if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
			uiView.becomeFirstResponder()
			context.coordinator.didBecomeFirstResponder = true
		}
	}
	
	init(_ placeholder: String?, text: Binding<String>) {
		self.placeholder = placeholder
		_text = text
	}
}
