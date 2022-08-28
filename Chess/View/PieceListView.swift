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
	
    var removePiece: (IndexSet) -> Void
    var addView: (Binding<Bool>) -> Content
    
	@State var isAddPieceViewShowing = false
	
	let rowColor = Color.rowColor
    
    init(pieceManager: PieceManager,
         removePiece: @escaping (IndexSet) -> Void,
         addView: @escaping (Binding<Bool>) -> Content) {
        self.pieceManager = pieceManager
        self.removePiece = removePiece
        self.addView = addView
    }
    
    func pieceImage(for piece: PieceModel) -> String {
        let owner = Player(rawValue: Int(piece.owner?.player ?? 0)) ?? .white
        let pieceImage = Piece.PieceImage(rawValue: Int(piece.pieceImage))?.imageName(owner: owner)
        return pieceImage ?? "white_pawn"
    }

    var body: some View {
		ZStack {
			List {
                ForEach($pieceManager.pieces) { $piece in
					NavigationLink(destination:
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
                    removePiece(indices)
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
                addView($isAddPieceViewShowing)
			}
		}
		
    }
}


