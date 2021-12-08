//
//  EditPatternView.swift
//  Chess
//
//  Created by Tyler Gee on 8/27/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct EditPatternView: View {
	
	@Environment(\.presentationMode) var presentationMode
	@Binding var isPresented: Bool
	
	// TODO: Refactor this into a view model
	
	//@State var pattern: Pattern
	@ObservedObject var viewModel: EditPatternViewModel
	var piece: Piece
	
	var title: String
	var didPressDone: (Pattern) -> Void
	
	@State var isOn: Bool = false
	
	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 0) {
				AddCancelHeader(
					title: title,
					isAddEnabled: true,
					onCancel: {
						isPresented = false
					},
					onAdd: {
						didPressDone(viewModel.pattern)
						isPresented = false
					},
					includeCancelButton: true,
					addButtonTitle: "Done"
				)
				
				Form {
					Section {
                        BoardView2(board: .constant(viewModel.board))
//						BoardView(
//                            squares: .constant(viewModel.squares),
//							selectedSquares: viewModel.selectedSquares,
//							legalMoves: [],
//							onSelected: { _ in },
//							makeSelectedSquaresRed: viewModel.isRestricting
//						)
						// TODO: refactor this into a custom BoardView styling view modifier
						.listRowBackground(Color.backgroundColor)
						.cornerRadius(8)
						.frame(width: geometry.size.width - 64, height: geometry.size.width - 64)
					}
					
					Picker("", selection: $viewModel.type) {
						ForEach(Pattern.PatternType.types, id: \.self) { type in
							Text(type.string)
						}
					}
					.pickerStyle(WheelPickerStyle())
					
					Section {
						Toggle("Restrict", isOn: $viewModel.isRestricting)
					}
					
					if let rankDistance = viewModel.rankDistance, let fileDistance = viewModel.fileDistance {
						Section {
							Stepper("\(rankDistance) Rank(s)", value: Binding($viewModel.rankDistance)!, in: 0...100)
							Stepper("\(fileDistance) File(s)", value: Binding($viewModel.fileDistance)!, in: 0...100)
						}
					}
					
					if let _ = viewModel.directions {
						Section {
							List(Move.Direction.directions, id: \.self, selection: $viewModel.directions) { direction in
								Text(direction.string)
							}
							.environment(\.editMode, .constant(.active))
						}
					}
				}
			}
			
		}
	}
	
	init(title: String, pattern: Pattern, piece: Piece, isPresented: Binding<Bool>, didPressDone: @escaping (Pattern) -> Void) {
		self.title = title
		self.viewModel = EditPatternViewModel(pattern: pattern, piece: piece)
		self.piece = piece
		self._isPresented = isPresented
		self.didPressDone = didPressDone
	}
}
