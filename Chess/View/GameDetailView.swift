//
//  GameDetailView.swift
//  Chess
//
//  Created by Tyler Gee on 8/10/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct GameDetailView: View {
	
	@EnvironmentObject var gameStore: GameManager
	@Environment(\.presentationMode) var presentationMode: Binding

	@Binding var game: Game
	
    var body: some View {
		GeometryReader { geometry in
			List {
                //GeometryReader { g in
                    Section {
                        BoardView2(board: $game.board)
                            .listRowBackground(Color.backgroundColor)
                            .listRowInsets(EdgeInsets())
                            //.frame(width: geometry.size.width - 64, height: (geometry.size.width - 64) * (CGFloat(game.board.ranks) / CGFloat(game.board.files)))
                            .disabled(true)
                    }
                    //.frame(width: g.size.width, height: (g.size.width) * (CGFloat(game.board.ranks) / CGFloat(game.board.files)))
                //}
				
				Section {
                    NavigationLink(destination: EditBoardView(game: game, changedGame: { game in
                        print("unchanged game: \(self.game.board.squares[0][0].piece?.name)")
                        print("does game == game? \(self.game == game)")
                        self.game = game
                        print("does game == game now? \(self.game == game)")
                        print("changed game: \(self.game.board.squares[0][0].piece?.name)")
                    })
                    ) {
						Text("Board")
					}
								   
					NavigationLink(destination:
						PieceListView(pieceManager: gameStore.pieceManager(for: game), game: $game)
							.environmentObject(gameStore)
					) {
						HStack {
							Text("Pieces")
							Spacer()
							Text("\(game.pieces.count)")
								.opacity(0.2)
						}
					}
				}
				.listRowBackground(Color.rowColor)
				
			}
			.listStyle(InsetGroupedListStyle())
			
		}
		.navigationBarTitle(game.name)//, displayMode: .inline)
		
    }

}

struct GameDetailView_Previews: PreviewProvider {
	
    static var previews: some View {
		//NavigationView {
		GameDetailView(game: .constant(Game.standard()))
		//}
    }
}
