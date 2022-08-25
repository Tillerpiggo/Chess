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
    
    //@Binding var piece: Piece
    @Binding var piece: PieceModel
    
    var body: some View {
//        let nameBinding = Binding<String>(get: {
//            piece.name
//        }, set: {
//            pieceManager.renamePiece(piece, to: $0)
//            piece.name = $0
//            // do whatever you want here
//        })
        
//        let isImportantBinding = Binding<Bool>(get: {
//            piece.isImportant
//        }, set: {
//            
//            piece.isImportant = $0
//        })
        
//        let canPromoteBinding = Binding<Bool>(get: {
//            piece.canPromote
//        }, set: {
//            pieceManager.setPieceCanPromote(piece, to: $0)
//            piece.canPromote = $0
//            print("canPromote: \(piece.canPromote)")
//        })
        
//        let promotionPieceManager = pieceManager.promotionPieceManager(for: pieceManager.pieces.first { $0.id == piece.id }!)
        //print("# of pieces: \(promotionPieceManager.pieces.count)")
        
        return List {
            Section {
                TextField("Piece name", text: $piece.name.toUnwrapped(defaultValue: ""))
                    .padding(.vertical, 16)
            }
            
            Section(footer: Text("When a player captures or checkmates all of the opponent’s important pieces, that player wins the game. In standard chess, only the King is important.")) {
                Toggle("Is Important", isOn: $piece.isImportant)
            }
//
//            Section {
//                NavigationLink(destination: PieceMovementEditorView(moverManager: pieceManager.moverManager(for: piece))) {
//                    Text("Movement")
//                }
//            }
            
            Section {
                Toggle("Can Promote", isOn: $piece.canPromote)
//                    .onChange(of: piece.canPromote) {
//                        print("$0: \($0)")
//                        pieceManager.setPieceCanPromote(piece, to: $0)
//                    }
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
        //Text("promotion pieces")
        PieceListView<AddPromotionPieceView>(
            pieceManager: promotionPieceManager,
            //pieces: pieceManager.promotionPieces(for: piece),//TODO,
//            pieceBinding: { promotionPiece in
//                guard let index = piece.promotionPieces.firstIndex(where: { $0.id == promotionPiece.id }) else { return nil }
//                return .init(get: { piece.promotionPieces[index] },
//                             set: {
//                    pieceManager.updatePiece($0)
//                    print("updating piece!!!")
//                })
//            },
            removePiece: { indices in
                //let index = indices.map { $0 }.first!
                //piece.promotionPieces?.remove(atOffsets: indices)

                //piece.promotionPieces?.remove(atOffsets: indices)
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
                                   
//    func makePieceBinding(_ piece: Piece) -> Binding<Piece>? {
//        guard let index = pieceManager.pieces.firstIndex(where: { $0.id == piece.id }) else { return nil }
//        return .init(get: { pieceManager.pieces[index] },
//                     set: { pieceManager.updatePiece($0) })
//    }
}
