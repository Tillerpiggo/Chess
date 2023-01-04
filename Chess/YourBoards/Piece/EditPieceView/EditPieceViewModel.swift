//
//  EditPieceViewModel.swift
//  Chess
//
//  Created by Tyler Gee on 8/11/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

class EditPieceViewModel: ObservableObject {
	@Published var name: String {
		didSet { piece.name = name; update() }
	}
	
	@Published var image: Piece.PieceImage {
		didSet { piece.image = image; update() }
	}
	
	@Published var canSavePiece: Bool = false
	@Published var hasChanged: Bool = false
	
	private(set) var piece: Piece
	private var initialPiece: Piece
	
	func update() {
		hasChanged = (piece != initialPiece)
		canSavePiece = !piece.name.isEmpty && hasChanged
	}
	
	init(piece: Piece) {
		self.piece = piece
		self.initialPiece = piece
		
		self.name = piece.name
		self.image = piece.image
	}
}
