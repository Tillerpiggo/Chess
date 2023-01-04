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
    @State var selectedPiece: Int = 0
    
    @Binding var isPresented: Bool
    
    var onAdd: (PieceModel) -> Void
    
    init(pieces: [PieceModel], isPresented: Binding<Bool>, onAdd: @escaping (PieceModel) -> Void) {
        self.pieces = pieces
        self._isPresented = isPresented
        self.onAdd = onAdd
    }
    
    var body: some View {
        VStack {
            AddCancelHeader(
                title: "Add Promotion Piece",
                isAddEnabled: true) {
                    self.isPresented = false
                } onAdd: {
                    self.onAdd(pieces[selectedPiece])
                    self.isPresented = false
                }
            Picker("Select a piece", selection: $selectedPiece) {
                ForEach(0..<pieces.count) { index in
                    Text(pieces[index].name ?? "")
                }
            }
            Spacer()
        }
        

    }
}
