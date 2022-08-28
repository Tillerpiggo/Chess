//
//  PieceDetailView.swift
//  Chess
//
//  Created by Tyler Gee on 8/15/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PieceDetailView: View {
	
    @ObservedObject var pieceManager: PieceManager
    
    @Binding var piece: PieceModel
    
    var body: some View {
        
        return List {
            Section {
                TextField("Piece name", text: $piece.name.toUnwrapped(defaultValue: ""))
                    .padding(.vertical, 16)
            }
            
            Section(footer: Text("When a player captures or checkmates all of the opponent’s important pieces, that player wins the game. In standard chess, only the King is important.")) {
                Toggle("Is Important", isOn: $piece.isImportant)
            }
            
            Section {
                NavigationLink(destination: PieceMovementEditorView(moverManager: pieceManager.moverManager(for: piece))) {
                    Text("Movement")
                }
            }
            
            Section {
                Toggle("Can Promote", isOn: $piece.canPromote)
                if piece.canPromote {
                    NavigationLink(destination: EditZoneView()) {
                        Text("Promotion Zone")
                    }
                    
                    NavigationLink("Can promote to", destination: pieceList)
                }
                    
            }
        }.listStyle(InsetGroupedListStyle())
            .navigationTitle((piece.name ?? "") == "" ? "Untitled Piece" : (piece.name ?? ""))
    }
    
    var pieceList: some View {
        PieceListView<AddPromotionPieceView>(
            pieceManager: promotionPieceManager,
            removePiece: { indices in
                pieceManager.removePromotionPiece(at: indices, from: piece)
            },

            addView: { isPresented in
                AddPromotionPieceView(
                    pieces: pieceManager.pieces.filter {
                        if let pieceID = $0.id, let promotionPieces = piece.promotionPieces {
                            return !promotionPieces.contains(pieceID)
                        } else {
                            return false
                        }
                    },
                    isPresented: isPresented) { newPiece in
                        pieceManager.addPromotionPiece(newPiece, to: piece)
                    }
            }
        )
    }
    
    var promotionPieceManager: PieceManager {
        return pieceManager.promotionPieceManager(for: piece)
    }
}
