//
//  AddBoardView.swift
//  Chess
//
//  Created by Tyler Gee on 8/3/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

/*
import SwiftUI
import Combine


// Can also be used as an AddBoardView if a new board is fed into it
struct EditGameView: View {
	
	@Environment(\.presentationMode) var presentationMode
	@Binding var isPresented: Bool
	
	@ObservedObject var viewModel: EditGameViewModel
	
	@State private var isConfirmDismissActionSheetShown = false
	@State private var hasBecomeFirstResponder = false
	
	@State private var whiteMovesFirst: Bool = true
	
	// This is just here so that the sheet view will update properly
	// TODO: Delete this as it is unnecessary whenever SwiftUI fixes this
	// (replace with just taking the value as an argument in init)
	
	var title: String
	var didPressDone: (Game) -> Void
	
	var body: some View {
		VStack {
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
			
			Form {
				Section {
					TextField("Name your board...", text: $viewModel.name)
				}
				
				Section {
					Toggle("White Moves First", isOn: $whiteMovesFirst)
				}
			}
			.actionSheet(isPresented: $isConfirmDismissActionSheetShown) {
				
				// TODO: Refactor this action sheet
				ActionSheet(
					title: Text("Are you sure you want to discard changes?"),
					buttons: [
						.destructive(Text("Discard Changes")) {
							isPresented = false
						},
						.cancel(Text("Continue Editing")) {
							// do nothing, just continue
						},
					]
				)
			}
			.presentation(isModal: viewModel.hasChanged) {
				isConfirmDismissActionSheetShown = true
			}
		}
	}
	
	init(title: String, game: Game, isPresented: Binding<Bool>, didPressDone: @escaping (Game) -> Void) {
		self.title = title
		self.viewModel = EditGameViewModel(game: game)
		print("game.name: \(game.name)")
		self._isPresented = isPresented
		self.didPressDone = didPressDone
	}
	
	/*
	init(title: String, game: Binding<Game>, isPresented: Binding<Bool>, didPressDone: @escaping (Game) -> Void) {
		self.title = title
		self._game = game
		self._isPresented = isPresented
		self.didPressDone = didPressDone
	}
*/
}
*/
