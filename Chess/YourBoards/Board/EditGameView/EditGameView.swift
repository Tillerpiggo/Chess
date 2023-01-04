//
//  BindingEditGameView.swift
//  Chess
//
//  Created by Tyler Gee on 8/5/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI
import Combine

struct EditGameView: View {
	
	@Environment(\.presentationMode) var presentationmode
	@Binding var isPresented: Bool
	
	@ObservedObject var viewModel: EditGameViewModel
	@State private var isConfirmDismissActionSheetShown = false
	
	var title: String
	var didPressDone: (Game) -> Void
	
	
	var body: some View {
		VStack(spacing: 0) {
			AddCancelHeader(
				title: title,
				isAddEnabled: viewModel.canSaveBoard,
				onCancel: {
					if !viewModel.hasChanged {
						isPresented = false
					} else {
						isConfirmDismissActionSheetShown = true
					}
				},
				onAdd: {
					didPressDone(viewModel.game)
					isPresented = false
				},
				includeCancelButton: true,
				addButtonTitle: "Done"
			)
			
			List {
				TextField("Name your board...", text: $viewModel.name)
                    .listRowBackground(Color.theme.secondary)
			}
			.listStyle(InsetGroupedListStyle())
			.confirmDismissActionSheet(
				isPresented: $isConfirmDismissActionSheetShown,
				isModalViewPresented: $isPresented
			)
			.presentation(isModal: viewModel.hasChanged) {
				isConfirmDismissActionSheetShown = true
			}
		}
	}
	
	init(title: String, game: Game, isPresented: Binding<Bool>, didPressDone: @escaping (Game) -> Void) {
		self.title = title
		self.viewModel = EditGameViewModel(game: game)
		self._isPresented = isPresented
		self.didPressDone = didPressDone
	}
	
}
