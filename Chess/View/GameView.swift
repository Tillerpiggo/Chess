//
//  GameView.swift
//  Chess
//
//  Created by Tyler Gee on 2/11/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct GameView: View {
	@ObservedObject var game: GameViewModel
	
	var body: some View {
		VStack {
			Text(victoryText)
			
            BoardView(squares: .constant(game.squares), selectedSquares: game.selectedSquares, legalMoves: game.legalMoves) { position in
				game.selectSquare(at: position)
			}
		}
	}
	
	var victoryText: String {
		switch game.gameState {
		case let .victory(player): return "\(player.string) Won!"
		case .onGoing: return ""
		case .draw: return "Draw!"
		}
	}
}
