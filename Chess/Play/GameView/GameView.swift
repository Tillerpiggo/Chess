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
	
    // TODO: Refactor GameView and EditBoardView to use the same code for dragging the board vs the pieces
    
    @State private var isPromoting = false
    
	var body: some View {
        GeometryReader { geometry in
            let squareLength = CGFloat(geometry.size.smallestSide) / 10
            ZStack {
                Color.white
                
                BoardView(
                    board: $game.game.board,
                    selectedSquares: game.selectedSquares,
                    legalMoves: game.legalMoves,
                    squareLength: squareLength,
                    onSelected: { selectedPosition in
                        game.selectSquare(at: selectedPosition)
                        
                        switch game.gameState {
                        case .promoting:
                            isPromoting = true
                        default: break
                        }
                    },
                    onDrag: { (startingPosition, endingPosition) in
                        game.onDrag(from: startingPosition, to: endingPosition)
                        
                        switch game.gameState {
                        case .promoting:
                            isPromoting = true
                        default: break
                        }
                    },
                    updateIsDraggingPiece: { isDraggingPiece in
                        self.isDraggingPiece = isDraggingPiece
                    }
                )
                .frame(width: squareLength * CGFloat(game.files),
                       height: squareLength * CGFloat(game.ranks)
                )
                
                if case .victory(let player) = game.gameState {
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 200, height: 50)
                    Text("\(player.string) won the game!")
                }
            }
            .offset(x: 0, y: -squareLength)
            .offset(panOffset)
            .animation(.spring(), value: panOffset)
            .scaleEffect(zoomScale)
            .simultaneousGesture(panGesture(sideLength: squareLength))
            .simultaneousGesture(zoomGesture())
        }
        .alert("Important message", isPresented: $isPromoting) {
            ForEach(game.promotablePieces, id: \.id) { piece in
                Button {
                    game.promoteTo(piece)
                } label: {
                    HStack {
                        Image(piece.imageName)
                        Text(piece.name)
                    }
                }

            }
        }
	}
    
    // Gestures
    @State var isDraggingPiece = false
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @State var steadyStateZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        gestureZoomScale *  steadyStateZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
                
                print("GestureZoomScale: \(gestureZoomScale)")
            }
            .onEnded { finalGestureScale in
                steadyStateZoomScale *= finalGestureScale
            }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    @State private var steadyStatePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        return (steadyStatePanOffset + gesturePanOffset) / zoomScale
    }
    
    private func panGesture(sideLength: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                if !isDraggingPiece {
                    gesturePanOffset = latestDragGestureValue.translation
                }
            }
            .onEnded { finalDragGestureValue in
                if !isDraggingPiece {
                    steadyStatePanOffset = steadyStatePanOffset + finalDragGestureValue.translation
                }
            }
    }
	
	var victoryText: String {
		switch game.gameState {
		case let .victory(player): return "\(player.string) Won!"
        case .onGoing, .promoting: return ""
		case .draw: return "Draw!"
		}
	}
}
