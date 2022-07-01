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
        }.listStyle(InsetGroupedListStyle())
            .navigationTitle(piece.name == "" ? "Untitled Piece" : piece.name)
    }
}
