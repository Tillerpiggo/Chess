//
//  EditBoardView.swift
//  Chess
//
//  Created by Tyler Gee on 9/2/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct EditBoardView: View {
	
	@State var game: Game
    var changedGame: (Game) -> Void
	
	var emptySquares: [[Square]] {
        let ranks = game.board.ranks + 2
        let files = game.board.files + 2
        let bottomLeftSquareColor: Square.SquareType = (ranks + files) % 2 == 0 ? .dark : .light
        let emptyBoard = Board.empty(ranks: game.board.ranks + 2, files: game.board.files + 2, bottomLeftSquareColor: bottomLeftSquareColor)
        
        //print("bot")
		
		return emptyBoard.squares
	}
	
	private var ranks: Int {
		return game.board.squares.first?.count ?? 0
	}
	
	private var files: Int {
		return game.board.squares.count
	}
	
    var body: some View {
		
		ZStack {
			Rectangle()
				.fill(Color.white)
				.ignoresSafeArea()
			
			GeometryReader { geometry in
				let squareLength = CGFloat(geometry.size.smallestSide) / CGFloat(game.board.squares.largestDimension)
				
				BoardView(
					squares: emptySquares,
					squareLength: squareLength,
					selectedSquares: [],
					legalMoves: [],
					onSelected: { selectedPosition in
						selectedPositionOnGhostBoard(selectedPosition, type: emptySquares[selectedPosition.file][selectedPosition.rank].type)
					}
				)
				.opacity(0.2)
				
				/*
				VStack {
					Spacer()
					Rectangle()
						.fill(Color.black)
						.aspectRatio(1, contentMode: .fit)
						.shadow(radius: 40)
					Spacer()
				}
*/
					
				
				
				BoardView(
					squares: game.board.squares,
					squareLength: squareLength,
					selectedSquares: [],
					legalMoves: [],
					onSelected: { (selectedPosition) in
						selectedPositionOnBoard(selectedPosition)
					},
					onDrag:
						{  (startingPosition, endingPosition) in
							if let move = Move(start: startingPosition, end: endingPosition) {
								game.move(move, onlyAllowLegalMoves: false)
							}
						},
					onDrop:
						{ (providers, rank, file) in
							self.drop(providers: providers, rank: rank, file: file)
						}
					)
				
					
					
			}
			.offset(panOffset)
			.scaleEffect(zoomScale)
			
			
			VStack {
				ZStack {
					Rectangle()
						.fill(Color.white.opacity(0.3))
						.cornerRadius(12)
					
					VisualEffectView(effect: UIBlurEffect(style: .regular))
					
					ScrollView(.horizontal) {
						HStack {
							ForEach(game.pieces) { piece in
								Image(piece.imageName)
									.resizable()
									.frame(width: 40, height: 40)
									.onDrag { NSItemProvider(object: piece.id.uuidString as NSString) }
							}
							
						}
					}
						.padding()
				}
				.frame(height: 60)
				
				Spacer()
			}
			
			
		}
			//.gesture(panGesture())
			.gesture(zoomGesture())
    }
    
    func selectedPositionOnBoard(_ selectedPosition: Position) {
        if game.board.squares[selectedPosition.file][selectedPosition.rank].state == .empty {
            game.board.squares[selectedPosition.file][selectedPosition.rank].state = .nonexistent
        }
    }
	
	func selectedPositionOnGhostBoard(_ selectedPosition: Position, type: Square.SquareType) {
		// Translate position to game board position
		let translatedPosition = Position(
			rank: selectedPosition.rank - 1,
			file: selectedPosition.file - 1
		)
		
		var squares = game.board.squares
		
		print("translatedPosition: \(translatedPosition)")
        
        var shouldUpdateSquarePositions: Bool = false
        var isTranslatedPositionInBoard: Bool = true
		
        // New square tapped on the left
		if translatedPosition.file < 0 {
			var newFile = [Square]()
			for rank in 0..<ranks {
				let state: Square.SquareState = rank == translatedPosition.rank ? .empty : .nonexistent
				
				
				newFile.append(Square(state: state, position: Position(rank: rank, file: 0), type: type))
			}
			
			squares.insert(newFile, at: 0)
            
            shouldUpdateSquarePositions = true
            isTranslatedPositionInBoard = false
		}
        
        // New square tapped on the right
        if translatedPosition.file >= files {
            var newFile = [Square]()
            for rank in 0..<ranks {
                let state: Square.SquareState = rank == translatedPosition.rank ? .empty : .nonexistent
                newFile.append(Square(state: state, position: Position(rank: rank, file: files), type: type))
            }
            
            squares.append(newFile)
            isTranslatedPositionInBoard = false
        }
        
        // New square tapped on the bottom
        if translatedPosition.rank < 0 {
            for (fileIndex, _) in squares.enumerated() {
                let state: Square.SquareState = fileIndex == translatedPosition.file ? .empty: .nonexistent
                
                let newSquare = Square(state: state, position: Position(rank: 0, file: fileIndex), type: type)
                
                squares[fileIndex].insert(newSquare, at: 0)
            }
            
            shouldUpdateSquarePositions = true
            isTranslatedPositionInBoard = false
        }
        
        // New square tapped on the top
        if translatedPosition.rank >= ranks {
            for (fileIndex, _) in squares.enumerated() {
                let state: Square.SquareState = fileIndex == translatedPosition.file ? .empty: .nonexistent
                
                let newSquare = Square(state: state, position: Position(rank: ranks, file: fileIndex), type: type)
                
                squares[fileIndex].append(newSquare)
            }
            isTranslatedPositionInBoard = false
        }
        
        // Square tapped inside existing board
        if isTranslatedPositionInBoard {
            squares[translatedPosition.file][translatedPosition.rank].state = .empty
            squares[translatedPosition.file][translatedPosition.rank].type = type
        }
        
		
        if shouldUpdateSquarePositions {
            // update all of the positions of all of the other squares
            for (fileIndex, file) in squares.enumerated() {
                for (rankIndex, _) in file.enumerated()
                {
                    squares[fileIndex][rankIndex].position = Position(rank: rankIndex, file: fileIndex)
                }
            }
        }
        
		game.board.squares = squares
        
        changedGame(game)
		
		/*
		if translatedPosition.rank < 0 {
			let newRank = [Square]()
			for 0..<files {
				newRank.append
			}
		}
*/
		
		
		if translatedPosition.rank >= ranks || translatedPosition.rank < 0 || translatedPosition.file >= files || translatedPosition.file < 0 {
			
			
		}
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
	
	private func panGesture() -> some Gesture {
		DragGesture()
			.updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
				gesturePanOffset = latestDragGestureValue.translation
			}
			.onEnded { finalDragGestureValue in
				steadyStatePanOffset = steadyStatePanOffset + finalDragGestureValue.translation
			}
	}
	
	private func drop(providers: [NSItemProvider], rank: Int, file: Int) {
        _ = providers.loadObjects(ofType: String.self) { id in
			if let piece = piece(id) {
				print("rank: \(rank), file: \(file)")
				game.board.squares[file][rank].setPiece(piece)
			}
		}
	}
	
	// Returns the rank and file on the board given a location
	private func coordinates(at location: CGPoint, in size: CGSize) -> (Int, Int) {
		let x = Int(location.x / (size.width / CGFloat(game.board.ranks)))
		let y = 7 - Int(location.y / (size.height / CGFloat(game.board.files)))
		
		return (x, y)
	}
	
	private func piece(_ id: String) -> Piece? {
		return game.pieces.first(where: { $0.id.uuidString == id })
	}
}

/*
struct EditBoardView_Previews: PreviewProvider {
    static var previews: some View {
		EditBoardView(board: Game.standard().board)
    }
}
*/
