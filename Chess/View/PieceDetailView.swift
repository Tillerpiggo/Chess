//
//  PieceDetailView.swift
//  Chess
//
//  Created by Tyler Gee on 8/15/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct PieceDetailView: View {
	
    @StateObject var pieceManager: PieceManager
    
    @Binding var piece: Piece
    
    var body: some View {
        let nameBinding = Binding<String>(get: {
            piece.name
        }, set: {
            pieceManager.renamePiece(piece, to: $0)
            piece.name = $0
            // do whatever you want here
        })
        
        let isImportantBinding = Binding<Bool>(get: {
            piece.isImportant
        }, set: {
            pieceManager.setPieceIsImportant(piece, to: $0)
            piece.isImportant = $0
        })
        
        let canPromoteBinding = Binding<Bool>(get: {
            piece.canPromote
        }, set: {
            pieceManager.setPieceCanPromote(piece, to: $0)
            piece.canPromote = $0
        })
        
        let promotionPieceManager = pieceManager.promotionPieceManager(for: piece)
        
        return List {
            Section {
                TextField("Piece name", text: nameBinding)
                    .padding(.vertical, 16)
            }
            
            Section(footer: Text("When a player captures or checkmates all of the opponent’s important pieces, that player wins the game. In standard chess, only the King is important.")) {
                Toggle("Is Important", isOn: isImportantBinding)
            }
            
            Section {
                NavigationLink(destination: PieceMovementEditorView(moverManager: pieceManager.moverManager(for: piece))) {
                    Text("Movement")
                }
            }
            
            Section {
                Toggle("Can Promote", isOn: canPromoteBinding)
                if piece.canPromote {
                    NavigationLink(destination: EditZoneView()) {
                        Text("Promotion Zone")
                    }
                    NavigationLink("Can promote to", destination: pieceList(promotionPieceManager: promotionPieceManager)
                    )
                }
            }
        }.listStyle(InsetGroupedListStyle())
            .navigationTitle(piece.name == "" ? "Untitled Piece" : piece.name)
    }
    
    func pieceList(promotionPieceManager: PieceManager) -> some View {
        PieceListView<EmptyView>(
            pieceManager: pieceManager,
            pieces: pieceManager.pieces.first { $0.id == piece.id }!.promotionPieces,//Binding.constant(pieceManager.pieces.filter { piece.promotionPieces.contains($0) }),
            pieceBinding: { piece in
                makePieceBinding(piece)!
            },
            
            removePiece: { indices in
                pieceManager.removePromotionPiece(at: indices, from: piece)
//                let index = indices.map { $0 }.first!
//                let removedPiece = promotionPieceManager.pieces[index]
//                piece.promotionPieces.removeAll { $0 == pieceID }
//                pieceManager.removePromotionPiece(removedPiece, from: piece)
            },
            
            addView: { isPresented in
                EmptyView()
//                EditPieceView(
//                    title: "Add Piece",
//                    piece: defaultPiece,
//                    isPresented: isPresented
//                ) { piece in
//                    pieceManager.addPiece(piece)
//                }
            }
        )
    }
                                   
    func makePieceBinding(_ piece: Piece) -> Binding<Piece>? {
        guard let index = pieceManager.pieces.firstIndex(where: { $0.id == piece.id }) else { return nil }
        return .init(get: { pieceManager.pieces[index] },
                     set: { pieceManager.updatePiece($0) })
    }
}
