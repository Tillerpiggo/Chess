//
//  YourBoardsView.swift
//  Chess
//
//  Created by Tyler Gee on 8/1/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct BoardListView: View {
	
	@EnvironmentObject var gameStore: GameManager
    @Environment(\.managedObjectContext) var managedObjectContext
	
	@State private var isAddBoardViewPresented: Bool = false
	@State private var isEditBoardViewPresented: Bool = false
	
	private let defaultGame = Game.standard()
	
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
	
	init() {
		UITableView.appearance().backgroundColor = UIColor(.backgroundColor)
	}
}

