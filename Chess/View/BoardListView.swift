//
//  YourBoardsView.swift
//  Chess
//
//  Created by Tyler Gee on 8/1/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct BoardListView: View {
	
	//@EnvironmentObject var gameStore: GameManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.title)) var students: FetchedResults<Student>
	
	//private var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
	
	@State private var isAddBoardViewPresented: Bool = false
	@State private var isEditBoardViewPresented: Bool = false
	
	private let defaultGame = Game.standard()
    //private let defaultGame = Game(board: Board.empty(ranks: 9, files: 1), pieces: [], players: [.white, .black], name: "")
	
	var body: some View {
		
		NavigationView {
			List {
                ForEach($gameStore.games, id: \.id) { $game in
					NavigationLink(destination:
                                    GameDetailView(pieceManager: gameStore.pieceManager(for: game), game: $game)
							.environmentObject(gameStore)
					) {
						HStack {
							Text(game.name ?? "Untitled Game")
                                .foregroundColor(.rowTextColor)
							Spacer()
						}//.contentShape(Rectangle())
						
					}
					.listRowBackground(Color.rowColor)
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle(Text("Your Boards"), displayMode: .large)
			.navigationBarItems(
				trailing: Button(action: {
					self.isAddBoardViewPresented = true
				}, label: {
					Image(systemName: "plus").imageScale(.large)
				})
			)
			.sheet(isPresented: $isAddBoardViewPresented) {
				EditGameView(title: "Add Game", game: defaultGame, isPresented: $isAddBoardViewPresented) { game in
					gameStore.addGame(game)
				}
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.navigationAppearance(
			backgroundColor: UIColor(.backgroundColor),
			foregroundColor: .black,
			tintColor: UIColor(.boardGreen),
			hideSeparator: true
		)
	}
	
//	func makeGameBinding(_ game: Game) -> Binding<Game>? {
//		guard let index = gameStore.games.firstIndex(where: { $0.id == game.id }) else { return nil }
//		return .init(get: { gameStore.games[index] },
//					 set: { gameStore.updateGame($0) })
//	}
	
	init() {
		UITableView.appearance().backgroundColor = UIColor(.backgroundColor)
	}
}

struct BoardTitleView: View {
	
	var game: Game
	
	var body: some View {
		//Text(game.title)
			//.bold()
		
		SingleAxisGeometryReader { width in
			VStack {
				// The point is to just display the starting position
                BoardView(squares: .constant(game.board.squares), selectedSquares: [], legalMoves: [], onSelected: { _ in }).frame(width: width, height: width)
				
				ZStack {
					Rectangle()
						.fill(Color.gray)
					
					VStack {
						Text(game.name)
							.bold()
					}
					.padding()
				}
			}
		}
	}
}

