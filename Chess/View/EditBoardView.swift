//
//  EditBoardView.swift
//  Chess
//
//  Created by Tyler Gee on 9/2/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct EditBoardView: View {
	
    @StateObject var model: EditBoardViewModel
    
    // Allow the pieces, not the board, to be dragged
    @State var isDragEnabled: Bool = true
    
    // True if isDraggingPiece
    @State var isDraggingPiece: Bool = true
    
    init(game: Binding<GameModel>, gameManager: GameManager) {
        self._model = StateObject(wrappedValue: EditBoardViewModel(game: game.wrappedValue) { game in
            gameManager.updateGame(game)
        })
    }
	
    private var ranks: Int { return model.ranks }
    private var files: Int { return model.files }
	
    var body: some View {
        GeometryReader { geometry in
            let squareLength = CGFloat(geometry.size.smallestSide) / 10
            ZStack {
                Color.white
                
                Group {
                    BoardView(
                        board: Binding<Board>(get: { model.emptyBoard }, set: { _ in }),
                        bottomLeftSquareColor: model.bottomLeftSquareColor,
                        squareLength: squareLength,
                        cornerRadius: 14,
                        onSelected: { selectedPosition in
                            print("selected: \(selectedPosition)")
                            let directionAdded = model.selectedPositionOnGhostBoard(selectedPosition)
                            
                            // It will only offset if added on the left/bottom
                            if directionAdded.rank > 0 {
                                steadyStatePanOffset.height -= squareLength * zoomScale
                            }
                            
                            if directionAdded.file < 0 {
                                steadyStatePanOffset.width -= squareLength * zoomScale
                            }
                        }
                    )
                        .opacity(0.2)
                        .frame(
                            width: squareLength * CGFloat(model.emptyBoard.files),
                            height: squareLength * CGFloat(model.emptyBoard.ranks)
                        )
                    
                    BoardView(
                        board: Binding<Board>(get: { model.board }, set: { _ in }),
                        squareLength: squareLength,
                        pieceOpacity: isDragEnabled ? 1 : 0.4,
                        onSelected: { selectedPosition in
                            //print("game.board.squares: \(game.board.squares.flatMap { $0 }.count)")
                            //print("selectedPosition: \(selectedPosition)")
                            if gesturePanOffset == .zero {
                                //withAnimation(.easeInOut) {
                                    let directionRemoved = model.selectedPositionOnBoard(selectedPosition)
                                    //selectedPositionOnBoard(selectedPosition, sideLength: squareLength)
                                    if directionRemoved.rank > 0 {
                                        steadyStatePanOffset.height += squareLength * CGFloat(abs(directionRemoved.rank)) * zoomScale
                                    }
                                    
                                    if directionRemoved.file < 0 {
                                        steadyStatePanOffset.width += squareLength * CGFloat(abs(directionRemoved.file)) * zoomScale
                                    }
                                //}
                                
                            }
                        },
                        onDrag: { (startingPosition, endingPosition) in
                            model.onDrag(from: startingPosition, to: endingPosition)
                        },
                        onDrop: { providers, position in
                            drop(providers: providers, position: position)
                        },
                        updateIsDraggingPiece: { isDraggingPiece in
                            self.isDraggingPiece = isDraggingPiece
                            print("isDraggingPiece: \(isDraggingPiece)")
                        }
                    )
                        .frame(
                            width: squareLength * CGFloat(model.files),
                            height: squareLength * CGFloat(model.ranks)
                        )
                           
                }
                .offset(x: 0, y: -squareLength)
                .offset(panOffset)
                .animation(.spring(), value: panOffset)
                .scaleEffect(zoomScale)
                              
                VStack {
                    Spacer()
                    HStack {
                        Picker("Test", selection: $model.selectedPlayer) {
                            ForEach([Player.white, Player.black], id: \.self) { player in
                                Text(player.string)
                            }
                        }
                        .padding(.leading, 32)
                        .tint(.boardGreen)
                        .pickerStyle(.menu)
                        
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 0) {
                                ForEach(model.pieces) { piece in
                                    ZStack {
                                        if model.selectedPiece == piece.id {
                                            Rectangle()
                                                .fill(Color(white: 0.4))
                                                .opacity(0.3)
                                                .frame(width: 48, height: 48)
                                                .cornerRadius(12)
                                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                                                .zIndex(0)
                                        }
                                        
                                        Image(piece.imageName)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .onTapGesture {
                                                print("selectedPiece!")
                                                model.selectedPiece(piece)
                                            }
                                            .padding(4)
                                            .onDrag {
                                                return NSItemProvider(object: piece.id.uuidString as NSString)
                                            }
                                    }
                                }
                                
                            }
                        }
                            .padding()
                            
                    }
                    .background(.thinMaterial)
                    
                }
                
                
            }
            .simultaneousGesture(panGesture(sideLength: squareLength))
            .simultaneousGesture(zoomGesture())
        }
        .navigationBarTitleDisplayMode(.inline)
    }
	
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
	
    private func drop(providers: [NSItemProvider], position: Position) {
        _ = providers.loadObjects(ofType: String.self) { id in
            print("id: \(id)")
            model.onDrop(id, at: position)
		}
	}
}
