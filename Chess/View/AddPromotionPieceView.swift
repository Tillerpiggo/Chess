//
//  AddPromotionPieceView.swift
//  Chess
//
//  Created by Tyler Gee on 7/10/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import SwiftUI
import CoreData

struct AddPromotionPieceView: View {
    
    var pieces: [PieceModel]
    @State var selectedPiece: PieceModel?
    
    @Binding var isPresented: Bool
    
    var onAdd: (PieceModel) -> Void
    
    init(pieces: [PieceModel], isPresented: Binding<Bool>, onAdd: @escaping (PieceModel) -> Void) {
        self.pieces = pieces
        self.selectedPiece = pieces.first ?? nil
        self._isPresented = isPresented
        self.onAdd = onAdd
    }
    
    var body: some View {
        VStack {
            AddCancelHeader(
                title: "Add Promotion Piece",
                isAddEnabled: selectedPiece != nil) {
                    self.isPresented = false
                } onAdd: {
                    self.onAdd(self.selectedPiece!)
                    self.isPresented = false
                }
            Picker("Select a piece", selection: $selectedPiece) {
                ForEach(pieces, id: \.id) { piece in
                    Text(piece.name ?? "")
                }
            }
            Spacer()
        }
        

    }
}
