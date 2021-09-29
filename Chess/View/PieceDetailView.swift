//
//  PieceDetailView.swift
//  Chess
//
//  Created by Tyler Gee on 8/15/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PieceDetailView: View {
	
	@StateObject var moverManager: MoverManager
	@ObservedObject var viewModel: PieceDetailViewModel
	
	@State var isAddPatternViewShowing = false
	
    var body: some View {
		GeometryReader { geometry in
			VStack(spacing: -2) {
				ZStack {
					Rectangle()
						.fill(Color.backgroundColor)
						.frame(height: 60)
					Picker("test", selection: $viewModel.selectedMovementType) {
						ForEach(viewModel.movementTypes, id: \.self) { type in
							Text(type.string)
						}
					}
					.padding()
					.pickerStyle(SegmentedPickerStyle())
				}
				
				List {
					Section {
						BoardView(
							squares: viewModel.squares,
							selectedSquares: viewModel.selectedSquares,
							legalMoves: [],
							onSelected: { _ in }
						)
						.listRowBackground(Color.backgroundColor)
						.cornerRadius(8)
						.frame(width: geometry.size.width - 64, height: geometry.size.width - 64)
					}
					
					Section(header: Text("Patterns")) {
						ForEach(viewModel.patterns) { pattern in
							patternView(pattern)
						}
						
						.onDelete { (patternIndex) in
							moverManager.removePattern(at: patternIndex, movementType: viewModel.selectedMovementType)
						}

						
						Button(action: {
							self.isAddPatternViewShowing = true
						}, label: {
							// TODO: Refactor this + button interface
							HStack {
								Image(systemName: "plus.circle.fill")
									.resizable()
									.frame(width: 24, height: 24)
								Text("Add Pattern")
							}
							.foregroundColor(Color.blue)
						})
						.listRowBackground(Color.rowColor)
					}
				}
				.listStyle(InsetGroupedListStyle())
			}
			.navigationBarTitle(Text(viewModel.piece.name), displayMode: .inline)
			.sheet(isPresented: $isAddPatternViewShowing) {
				EditPatternView(
					title: "Add Pattern",
					pattern: Pattern(.horizontal),
					piece: viewModel.piece,
					isPresented: $isAddPatternViewShowing
				) { pattern in
					//piece.mover.canMovePatterns.append(pattern)
					moverManager.addPattern(pattern, movementType: viewModel.selectedMovementType)
				}
			}
		}
    }
	
	func patternView(_ pattern: Pattern) -> some View {
		Text(pattern.string)
	}
	
	init(moverManager: MoverManager) {
		self._moverManager = StateObject(wrappedValue: moverManager)
		self.viewModel = PieceDetailViewModel(moverManager: moverManager)
		//self.piece = piece
		//self.piece.position = Position(rank: 3, file: 3)
		
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.boardGreen)
		UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor(.white)], for: .selected)
	}
}

/*
struct PieceDetailView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			PieceDetailView(piece: .constant(Piece.king(position: Position(rank: 0, file: 0), owner: .white)), gameStore: GameManager(gameManager: <#T##ModelManager<GameModel>#>), game: .constant(Game.standard()))
		}
    }
}
*/
