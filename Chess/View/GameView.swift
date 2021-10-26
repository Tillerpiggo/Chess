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
        GeometryReader { geometry in
//
//                VStack(spacing: 0) {
//                    Spacer()
//                    HStack(spacing: 0) {
//                        Spacer()
//                        BoardView(
//                            squares: .constant(game.squares),
//                            isReversed: game.isReversed,
//                            activePlayer: game.activePlayer,
//                            selectedSquares: game.selectedSquares,
//                            legalMoves: game.legalMoves,
//                            onSelected: { position in
//                                print("selected square!")
//                                game.selectSquare(at: position)
//                            },
//                            onDrag: { startingPosition, endingPosition in
//                                game.selectSquare(at: startingPosition)
//                                game.selectSquare(at: endingPosition)
//                            }
//                        )
//                        .frame(width: geometry.size.width, height: (geometry.size.width) * (CGFloat(game.ranks) / CGFloat(game.files)))
//
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }
            VStack(spacing: 0) {
                Spacer()
                Text(victoryText)
                BoardView(
                    squares: .constant(game.squares),
                    isReversed: game.isReversed,
                    activePlayer: game.activePlayer,
                    selectedSquares: game.selectedSquares,
                    legalMoves: game.legalMoves,
                    onSelected: { position in
                        print("selected square!")
                        game.selectSquare(at: position)
                    },
                    onDrag: { startingPosition, endingPosition in
                        game.selectSquare(at: startingPosition)
                        game.selectSquare(at: endingPosition)
                    }
                )
                .frame(width: geometry.size.width, height: (geometry.size.width) * (CGFloat(game.ranks) / CGFloat(game.files)))
                
                Spacer()
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
