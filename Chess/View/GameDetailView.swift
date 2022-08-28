//
//  GameDetailView.swift
//  Chess
//
//  Created by Tyler Gee on 8/10/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct GameDetailView: View {
	
	@EnvironmentObject var gameManager: GameManager
    @ObservedObject var pieceManager: PieceManager
	@Environment(\.presentationMode) var presentationMode: Binding

	@Binding var game: GameModel
    
    private let lengthPercent: CGFloat = 0.82//0.908 // percent of the width that views in the list take up
    private let totalMargin: CGFloat = 0
    
    var defaultPiece: Piece = {
        var pawn = Piece.whitePawn(position: Position(rank: 0, file: 0))
        pawn.name = ""
        
        return pawn
    }()
	
    var body: some View {
        
		return GeometryReader { geometry in
                
                List {
                    
                    Section {
                        HStack {
                            Spacer()
                            BoardView(board: Binding<Board>(get: { game.gameStruct!.board }, set: { _ in }), squareLength: (geometry.size.width * lengthPercent - totalMargin) / CGFloat(game.files), cornerRadius: 8)
                                .frame(width: geometry.size.width * lengthPercent - totalMargin, height: (geometry.size.width * lengthPercent - totalMargin) * CGFloat(game.ranks) / CGFloat(game.files))
                            Spacer()
                        }
                        
                    }
                    
                    .listRowBackground(Color.backgroundColor)
                    .listRowInsets(EdgeInsets())
                    .disabled(true)
                    
                    Section {
                        NavigationLink(destination: EditBoardView(game: $game, gameManager: gameManager))
                        {
                            Text("Board")
                                .foregroundColor(.rowTextColor)
                        }
                                       
                        NavigationLink(destination: pieceList)
                        {
                            HStack {
                                Text("Pieces")
                                    .foregroundColor(.rowTextColor)
                                Spacer()
                                Text("\(game.pieces?.count ?? 0)")
                                    .foregroundColor(.rowTextColor)
                                    .opacity(0.2)
                            }
                        }
                    }
                    .listRowBackground(Color.rowColor)
                    
                }
                .listStyle(InsetGroupedListStyle())
            //}
            
			
		}
		.navigationBarTitle(game.name ?? "Untitled Game", displayMode: .inline)
		
    }
    
    var pieceList: some View {
        PieceListView<EditPieceView>(
            pieceManager: pieceManager,
            removePiece: { index in
                pieceManager.removePiece(at: index)
            },
            
            addView: { isPresented in
                EditPieceView(
                    title: "Add Piece",
                    piece: defaultPiece,
                    isPresented: isPresented
                ) { piece in
                    pieceManager.addPiece(piece)
                }
            }
        )
        .environmentObject(gameManager)
    }

}
