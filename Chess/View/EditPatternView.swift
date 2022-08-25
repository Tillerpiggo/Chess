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
    
    private let lengthPercent: CGFloat = 0.82//0.908 // percent of the width that views in the list take up
    private let totalMargin: CGFloat = 0
	
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
                        HStack {
                            Spacer()
                            BoardView2(
                                board: Binding<Board>(get: { viewModel.board }, set: { _ in }),
                                selectedSquares: viewModel.selectedSquares,
                                selectionColor: viewModel.isRestricting ? .excludedSquareColor : .selectedSquareColor,
                                squareLength: (geometry.size.width * lengthPercent - totalMargin) / CGFloat(viewModel.board.files),
                                cornerRadius: 8)
                                .frame(width: geometry.size.width * lengthPercent - totalMargin, height: (geometry.size.width * lengthPercent - totalMargin) * CGFloat(viewModel.board.ranks) / CGFloat(viewModel.board.files))
                            Spacer()
                        }
                        
                    }
                    .listRowBackground(Color.backgroundColor)
                    .listRowInsets(EdgeInsets())
                    .disabled(true)
					
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
