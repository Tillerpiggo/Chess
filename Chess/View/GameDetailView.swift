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
        //let pieceManager = gameManager.pieceManager(for: game)
        
		return GeometryReader { geometry in
//            ScrollView {
//                VStack {
//                    BoardView2(board: $game.board, squareLength: geometry.size.width - 48)
//
//                    // First section
//                }
//            }
            
            
            //VStack(spacing: 0) {
                
                List {
                    //GeometryReader { g in
                        //Section {
    //                        BoardView2(board: $game.board, squareLength: (geometry.size.width * lengthPercent - totalMargin) / CGFloat(game.board.files))
    //                            .frame(width: geometry.size.width * lengthPercent - totalMargin, height: (geometry.size.width * lengthPercent - totalMargin) * (CGFloat(max(game.board.ranks, game.board.files)) / CGFloat(min(game.board.ranks, game.board.files))))
                                
                        //}
                        //.listRowBackground(Color.backgroundColor)
                        //.listRowInsets(EdgeInsets())
                        //.disabled(true)
                        //.frame(width: g.size.width, height: (g.size.width) * (CGFloat(game.board.ranks) / CGFloat(game.board.files)))
                    //}
                    
                    Section {
                        HStack {
                            Spacer()
                            BoardView2(board: Binding<Board>(get: { game.gameStruct!.board }, set: { _ in }), squareLength: (geometry.size.width * lengthPercent - totalMargin) / CGFloat(game.files), cornerRadius: 8)
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
            //pieces: pieceManager.pieces,
//            pieceBinding: { piece in
//                guard let index = game.pieces.firstIndex(where: { $0.id == piece.id }) else { return nil }
//                return .init(get: { game.pieces[index] },
//                             set: { pieceManager.updatePiece($0) })
//            },
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

//struct GameDetailView_Previews: PreviewProvider {
//
//    static var previews: some View {
//		//NavigationView {
//		GameDetailView(game: .constant(Game.standard()))
//		//}
//    }
//}
