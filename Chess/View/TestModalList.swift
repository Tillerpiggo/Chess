//
//  TestModalList.swift
//  Chess
//
//  Created by Tyler Gee on 8/4/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//
/*
import SwiftUI

struct TestModalList: View {
	let games: [Game] = [Game(board: Board.empty, players: [.white, .black], name: "WOOOO")]
	@State private var selectedFuck: Game = Game(board: Board.empty, players: [.white, .black], name: "")
	@State private var showModal: Bool = false
	
	var body: some View {
		List {
			ForEach(0..<self.games.count) { index in
				HStack {
					Text(self.games[index].name)
					Text("Animal \(index)")
				}
				.onTapGesture {
					self.selectedFuck = self.games[index]
					self.showModal = true
					
					//print(selectedFuck)
				}
			}
		}
		/*
		.sheet(isPresented: $showModal) {
			Text(selectedFuck.name)
			//EditGameView(title: "WOO", game: $selectedFuck, isPresented: $showModal, didPressDone: { game in })
			//FuckView(randomOtherVariable: 5, selectedFuck: $selectedFuck)
		}
*/
		/*
		.alert(isPresented: $showModal) {
			Alert(title: Text(selectedFuck.name))
		}
*/
	}
}

struct FuckView: View {
	@Binding var selectedFuck: Game
	var randomOtherVariable: Int
	@Binding var stupidVariable: Game
	
	var body: some View {
		Text(stupidVariable.name)
	}
	
	init(randomOtherVariable: Int, selectedFuck: Binding<Game>) {
		self.randomOtherVariable = randomOtherVariable
		self._selectedFuck = selectedFuck
		self._stupidVariable = selectedFuck
		print(selectedFuck.wrappedValue.name)
		print("Hello?")
	}
}
*/
