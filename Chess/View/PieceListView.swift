//
//  PieceListView.swift
//  Chess
//
//  Created by Tyler Gee on 8/10/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PieceListView<Content>: View where Content: View {
    
	@ObservedObject var pieceManager: PieceManager
	
	//@Binding var game: Game
    //@State var pieces: [Piece]
    //var pieceBinding: (Piece) -> (Binding<Piece>)
    var removePiece: (IndexSet) -> Void
    var addView: (Binding<Bool>) -> Content
    
	@State var isAddPieceViewShowing = false
	
	let rowColor = Color.rowColor
	
//	func pieceBinding(from piece: Piece) -> Binding<Piece> {
//		let index = game.pieces.firstIndex(where: { $0.id == piece.id })!
//		return $game.pieces[index]
//	}
    
    init(pieceManager: PieceManager,
         //pieces: [Piece],
         removePiece: @escaping (IndexSet) -> Void,
         addView: @escaping (Binding<Bool>) -> Content) {
        self.pieceManager = pieceManager
        //self._pieces = State(wrappedValue: pieces)
        self.removePiece = removePiece
        self.addView = addView
    }
    
    func pieceImage(for piece: PieceModel) -> String {
        let owner = Player(rawValue: Int(piece.owner?.player ?? 0)) ?? .white
        let pieceImage = Piece.PieceImage(rawValue: Int(piece.pieceImage))?.imageName(owner: owner)
        return pieceImage ?? "white_pawn"
    }
//
    var body: some View {
		ZStack {
			List {
                ForEach($pieceManager.pieces) { $piece in
					NavigationLink(destination:
									//PieceMovementEditorView(moverManager: pieceManager.moverManager(for: piece))
//                                   PieceDetailView(pieceManager: pieceManager, piece: $piece)//pieceBinding(for: piece)!)
                                   PieceDetailView(pieceManager: pieceManager, piece: $piece)
					) {
						HStack {
                            // TODO: abstract this into a viewmodel
                            Image(pieceImage(for: piece))
								.resizable()
								.frame(width: 32, height: 32)
                            Text(piece.name ?? "")
                            Spacer()
                            if piece.isImportant {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.boardGreen)
                            }
						}
					}
                    .listRowBackground(rowColor)
				}
				.onMove { (source, destination) in
					pieceManager.movePiece(from: source, to: destination)
				}
				.onDelete { (indices) in
					//pieceManager.removePiece(at: pieceIndex)
                    // remove it here for sake of UI updating quickly
//                    let index = pieceIndex.map { $0 }.first!
//                    pieces.remove(at: index)
                    
                    removePiece(indices)
                    
                    // Remove it in the backend
                    //pieceManager.removePiece(at: indices)
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
//				EditPieceView(
//					title: "Add Piece",
//					piece: defaultPiece,
//					isPresented: $isAddPieceViewShowing
//				) { piece in
//					pieceManager.addPiece(piece)
//				}
                addView($isAddPieceViewShowing)
			}
		}
		
    }
    
//    func pieceBinding(for boundPiece: Piece) -> Binding<Piece>? {
//        guard let piece = pieceManager.pieces.first(where: { $0.id == boundPiece.id }) else { return nil }
//        return Binding<Piece>(
//            get: {
//                return piece
//            },
//            set: {
//                pieceManager.updatePiece($0)
//            }
//        )
//    }
}

/*
struct PieceListView_Previews: PreviewProvider {
    static var previews: some View {
		PieceListView(game: .constant(Game.standard()))
    }
}
*/
