//
//  PieceListView.swift
//  Chess
//
//  Created by Tyler Gee on 8/10/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PieceListView: View {
	
	@StateObject var pieceManager: PieceManager
	
	@Binding var game: Game
	@State var isAddPieceViewShowing = false
	
	var defaultPiece: Piece = {
		var pawn = Piece.pawn(position: Position(rank: 0, file: 0), owner: .white)
		pawn.name = ""
		
		return pawn
	}()
	
	let rowColor = Color.rowColor
	
	func pieceBinding(from piece: Piece) -> Binding<Piece> {
		let index = game.pieces.firstIndex(where: { $0.id == piece.id })!
		return $game.pieces[index]
	}
	
    var body: some View {
		ZStack {
			List {
				ForEach(game.pieces) { piece in
					NavigationLink(destination:
									PieceDetailView(moverManager: pieceManager.moverManager(for: piece))
					) {
						HStack {
							Image(piece.imageName)
								.resizable()
								.frame(width: 32, height: 32)
							Text(piece.name)
						}
					}
                    .listRowBackground(rowColor)
				}
				.onMove { (source, destination) in
					pieceManager.movePiece(from: source, to: destination)
				}
				.onDelete { (pieceIndex) in
					pieceManager.removePiece(at: pieceIndex)
				}
				
				Button(action: {
					self.isAddPieceViewShowing = true
				}, label: {
					HStack {
						Image(systemName: "plus.circle.fill")
							.resizable()
							.frame(width: 24, height: 24)
						Text("Add Piece")
					}
					.foregroundColor(Color.blue)
					
				})
				.listRowBackground(rowColor)
				.onTapGesture {
					self.isAddPieceViewShowing = true
				}
			}
			.navigationBarTitle(Text("Pieces"), displayMode: .inline)
			.toolbar { EditButton() }
			.listStyle(InsetGroupedListStyle())
			.sheet(isPresented: $isAddPieceViewShowing) {
				EditPieceView(
					title: "Add Piece",
					piece: defaultPiece,
					isPresented: $isAddPieceViewShowing
				) { piece in
					pieceManager.addPiece(piece)
				}
			}
		}
		
    }
}

/*
struct PieceListView_Previews: PreviewProvider {
    static var previews: some View {
		PieceListView(game: .constant(Game.standard()))
    }
}
*/
