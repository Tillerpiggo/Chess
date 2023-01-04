//
//  YourBoardsView.swift
//  Chess
//
//  Created by Tyler Gee on 8/1/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct YourBoardsView: View {
    @EnvironmentObject var gameManager: CoreDataGameManager
    
    var body: some View {
        YourBoardsViewInternal<CoreDataGameManager>()
            .environmentObject(gameManager)
    }
}

struct YourBoardsViewInternal<ViewModel: GameManager>: View {
	
	@EnvironmentObject var gameManager: ViewModel
    //@Environment(\.managedObjectContext) var managedObjectContext
	
	@State private var isAddBoardViewPresented: Bool = false
	@State private var isEditBoardViewPresented: Bool = false
	
	//private let defaultGame = Game.standard
	
	var body: some View {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    ScrollView {
                        ForEach(gameManager.games, id: \.id) { game in
                            NavigationLink(destination: EmptyView()
                                           //BoardDetailView(pieceManager: gameStore.pieceManager(for: game), game: $game)
                                           //.environmentObject(gameStore)
                            ) {
                                HStack {
                                    GameRow(game: game)
                                }
                                
                            }
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
                        //                    EditGameView(title: "Add Game", game: defaultGame, isPresented: $isAddBoardViewPresented) { game in
                        //                        gameManager.addGame(game)
                        //                    }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationAppearance(
                backgroundColor: UIColor(.theme.background),
                foregroundColor: UIColor(.theme.primaryText),
                tintColor: UIColor(.theme.accent),
                hideSeparator: true
            )
	}
	
	init() {
        UITableView.appearance().backgroundColor = UIColor(.theme.background)
	}
}

struct GameRow: View {
    
    var game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(game.name)
                .foregroundColor(.theme.primaryText)
                .font(.system(size: 18))
                .fontWeight(.bold)
            Text(game.id.uuidString)
                .foregroundColor(.theme.secondaryText)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.primary)
        }
        .padding(.vertical, 6)
    }
}

struct YourBoardsView_Previews: PreviewProvider {
    static var previews: some View {
        YourBoardsViewInternal<MockGameManager>()
            .environmentObject(dev.gameManager)
    }
}

