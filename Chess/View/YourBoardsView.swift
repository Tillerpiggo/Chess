//
//  YourBoardsView.swift
//  Chess
//
//  Created by Tyler Gee on 8/1/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct BoardListView: View {
	
	// Test Data
	var boards: [Game] = {
		var boards = [Game]()
		for i in 0..<5 {
			var newBoard = Game(board: Board.empty, players: [.white, .black], title: "Board \(i)")
			boards.append(newBoard)
		}
		
		return boards
	}()
	
	var body: some View {
		
	}
}
