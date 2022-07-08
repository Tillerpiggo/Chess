//
//  ChessApp.swift
//  Chess
//
//  Created by Tyler Gee on 2/8/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

@main

struct ChessApp: App {
	
	let persistenceController = PersistenceController.shared
	
	@Environment(\.scenePhase) var scenePhase
	
	
	@StateObject var game: GameViewModel = {
		
		let players: [Player] = [.white, .black]
		
        let game = Game.standard()
		
		return GameViewModel(game: game)
	}() 

	
	@StateObject var gameStore: GameManager =
		GameManager(
			gameManager: ModelManager<GameModel>(persistenceController: PersistenceController.shared,
												 sortDescriptors: [NSSortDescriptor(keyPath: \GameModel.name, ascending: true)])
		)
	
	var body: some Scene {
		WindowGroup {
            
            TabView {
                BoardListView()
                    .environmentObject(gameStore)
                    .tabItem {
                        Text("Your Games")
                    }
                PlayView()
                    .environmentObject(gameStore)
                    .tabItem {
                        Text("Play")
                    }
            }
            .onAppear {
                UITableView.appearance().separatorColor = UIColor(Color.separatorColor)
            }
             
            //GameView(game: game)
		}
		.onChange(of: scenePhase) { _ in
			persistenceController.save()
		}
	}
}
