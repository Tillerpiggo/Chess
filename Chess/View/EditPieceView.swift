//
//  EditPieceView.swift
//  Chess
//
//  Created by Tyler Gee on 8/11/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct EditPieceView: View {
	
	@Binding var isPresented: Bool
	
	var title: String
	var didPressDone: (Piece) -> Void
	
	@ObservedObject var viewModel: EditPieceViewModel
	
    var body: some View {
		VStack(spacing: 0) {
			AddCancelHeader(
				title: title,
				isAddEnabled: viewModel.canSavePiece,
				onCancel: {
					if !viewModel.hasChanged {
						isPresented = false
					}
				},
				onAdd: {
					didPressDone(viewModel.piece)
					isPresented = false
				},
				includeCancelButton: true,
				addButtonTitle: "Add"
			)
			
			Form {
				TextField("Piece name...", text: $viewModel.name)
					.listRowBackground(Color.rowColor)
			}
		}
    }
	
	init(title: String, piece: Piece, isPresented: Binding<Bool>, didPressDone: @escaping (Piece) -> Void) {
		self.title = title
		self.viewModel = EditPieceViewModel(piece: piece)
		self._isPresented = isPresented
		self.didPressDone = didPressDone
	}
}

struct EditPieceView_Previews: PreviewProvider {
    static var previews: some View {
        EditPieceView(
			title: "Add Piece",
			piece: Piece.rook(position: Position(rank: 0, file: 0), owner: .white),
			isPresented: .constant(true),
			didPressDone: { piece in }
		)
    }
}
