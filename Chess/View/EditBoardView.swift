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
    
    @State var bottomLeftSquareColor: Square.SquareType = .dark
    @State var isDragEnabled: Bool = false
    
    private func toggleBottomLeftSquareColor() {
        if self.bottomLeftSquareColor == .light {
            self.bottomLeftSquareColor = .dark
        } else {
            self.bottomLeftSquareColor = .light
        }
        
        print("toggled to \(self.bottomLeftSquareColor)")
    }
	
	var emptySquares: [[Square]] {
        //let ranks = game.board.ranks + 2
        //let files = game.board.files + 2
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
        GeometryReader { geometry in
            let squareLength = CGFloat(geometry.size.smallestSide) / 8
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .ignoresSafeArea()
                
                Group {
                    
                    
                    BoardView(
                        squares: .constant(emptySquares),
                        squareLength: squareLength,
                        isDragEnabled: isDragEnabled,
                        selectedSquares: [],
                        legalMoves: [],
                        onSelected: { selectedPosition in
                            selectedPositionOnGhostBoard(selectedPosition, type: emptySquares[selectedPosition.file][selectedPosition.rank].type)
                        }
                    )
                    .opacity(0.2)
                    .offset(x: squareLength * -1, y: squareLength * -1)
                    
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
                        squares: $game.board.squares,
                        squareLength: squareLength,
                        isDragEnabled: isDragEnabled,
                        selectedSquares: [],
                        legalMoves: [],
                        onSelected: { (selectedPosition) in
                            selectedPositionOnBoard(selectedPosition)
                        },
                        onDrag:
                            {  (startingPosition, endingPosition) in
                                if let move = Move(start: startingPosition, end: endingPosition), game.board.squares[endingPosition]?.state != .nonexistent {
                                    print("was: \(self.game.board.squares[0][0].piece?.name)")
                                    //self.game.move(move)
                                    game.moveSetup(move)
                                    
                                    print("is: \(game.board.squares[0][0].piece?.name)")
                                    changedGame(game)
                                }
                            },
                        onDrop:
                            { (providers, rank, file) in
                                self.drop(providers: providers, rank: rank, file: file)
                            }
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 20)
                    
                        
                        
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
            //.gesture(!isDragEnabled ? zoomGesture() : nil)
            .gesture(!isDragEnabled ? panGesture(sideLength: squareLength) : nil)
            .toolbar {
                Button(isDragEnabled ? "Move Board" : "Move Pieces") {
                    isDragEnabled.toggle()
                }
            }
            .onAppear {
                bottomLeftSquareColor = game.board.squares[0][0].type
                print("bottomLeftSquareColor: \(bottomLeftSquareColor)")
            }
        }
    }
    
    func selectedPositionOnBoard(_ selectedPosition: Position) {
        print("selected: \(selectedPosition)")
        if game.board.squares[selectedPosition.file][selectedPosition.rank].state == .empty {
            print("actuallySelected: \(selectedPosition)")
            game.board.squares[selectedPosition.file][selectedPosition.rank].state = .nonexistent
            
            // Remove row/file if there is nothing left in it and it's on the edge
            trimSquaresIfNecessary(&game.board.squares, afterSquareRemovedAt: selectedPosition)
            
            changedGame(game)
        }
    }
	
	func selectedPositionOnGhostBoard(_ selectedPosition: Position, type: Square.SquareType) {
		// Translate position to game board position
		var translatedPosition = Position(
			rank: selectedPosition.rank - 1,
			file: selectedPosition.file - 1
		)
		
		var squares = game.board.squares
		
		print("translatedPosition: \(translatedPosition)")
        
        var shouldUpdateSquarePositions: Bool = false
        var isTranslatedPositionInBoard: Bool = true
		
        // New square tapped on the left
		if translatedPosition.file < 0 {
            print("tapped on left")
			var newFile = [Square]()
			for rank in 0..<ranks {
				let state: Square.SquareState = rank == translatedPosition.rank ? .empty : .nonexistent
                let position = Position(rank: rank, file: 0)
                
                // If it is an even number of ranks away, it should be in the same order
                let squareType = ((selectedPosition.rank - rank) % 2 == 0) ? type : type.opposite
                print("selectedPosition.rank: \(selectedPosition.rank), rank: \(rank)")
                newFile.append(Square(state: state, position: position, type: squareType))
			}
			
			squares.insert(newFile, at: 0)
            
            translatedPosition.file += 1
            
            shouldUpdateSquarePositions = true
            isTranslatedPositionInBoard = false
            
            toggleBottomLeftSquareColor()
            
            print("0, 0 square \(squares[0][0].state)")
		}
        
        // New square tapped on the right
        if translatedPosition.file >= files {
            print("tapped on right")
            var newFile = [Square]()
            for rank in 0..<ranks {
                let state: Square.SquareState = rank == translatedPosition.rank ? .empty : .nonexistent
                let position = Position(rank: rank, file: files)
                
                // If it is an even number of ranks away, it should be in the same order
                let squareType = (selectedPosition.rank - rank) % 2 == 0 ? type : type.opposite
                newFile.insert(Square(state: state, position: position, type: squareType), at: rank)
            }
            
            squares.append(newFile)
            isTranslatedPositionInBoard = false
        }
        
        // New square tapped on the bottom
        if translatedPosition.rank < 0 {
            print("tapped on bottom")
            for (fileIndex, _) in squares.enumerated() {
                let state: Square.SquareState = fileIndex == translatedPosition.file ? .empty: .nonexistent
                let position = Position(rank: 0, file: fileIndex)
                
                // If it is an even number of files away, it should be in the same order
                let squareType = (selectedPosition.file - fileIndex) % 2 == 0 ? type : type.opposite
                let newSquare = Square(state: state, position: position, type: squareType)
                
                squares[fileIndex].insert(newSquare, at: 0)
            }
            
            shouldUpdateSquarePositions = true
            isTranslatedPositionInBoard = false
            
            toggleBottomLeftSquareColor()
            
            print("0, 0 square \(squares[0][0].state)")
        }
        
        // New square tapped on the top
        if translatedPosition.rank >= ranks {
            print("tapped on top")
            
            for (fileIndex, _) in squares.enumerated() {
                let state: Square.SquareState = fileIndex == translatedPosition.file ? .empty: .nonexistent
                let position = Position(rank: ranks, file: fileIndex)
                
                // If it is an even number of files away, it should be in the same order
                let squareType = (selectedPosition.file - fileIndex) % 2 == 0 ? type : type.opposite
                let newSquare = Square(state: state, position: position, type: squareType)
                
                print("Added square: \(newSquare.state), to file: \(fileIndex), at: \(position)")
                
                print("squares[\(fileIndex)]: \(squares[fileIndex].count)")
                squares[fileIndex].insert(newSquare, at: ranks)
                print("squares[\(fileIndex)]: \(squares[fileIndex].count)")
            }
            isTranslatedPositionInBoard = false
            
            print("squares[0]: \(squares[0].count)")
        }
        
        // Square tapped inside existing board
        if isTranslatedPositionInBoard {
            print("tapped in board")
            withAnimation {
                squares[translatedPosition.file][translatedPosition.rank].state = .empty
            }
            squares[translatedPosition.file][translatedPosition.rank].type = type
        }
		
        if shouldUpdateSquarePositions {
            updateSquarePositions(&squares)
        }
        
        print("squares[0]: \(squares[0].count)")
        
        print("file length before: \(game.board.squares[0].count)")
		game.board.squares = squares
        print("file length after: \(game.board.squares[0].count)")
        print("squares[0]: \(squares[0].count)")
        
        if game.board.squares == squares {
            print("they're the same")
        } else {
            print("they're different")
        }
        
        changedGame(game)
	}
    
    private func updateSquarePositions(_ squares: inout [[Square]]) {
        print("updated square positions")
        // update all of the positions of all of the other squares
        for (fileIndex, file) in squares.enumerated() {
            for (rankIndex, _) in file.enumerated()
            {
                squares[fileIndex][rankIndex].position = Position(rank: rankIndex, file: fileIndex)
            }
        }
    }
    
    private func trimSquaresIfNecessary(_ squares: inout [[Square]], afterSquareRemovedAt removedPosition: Position) {
        
        // Position placed to collapse the board if an island is removed
        var checkPosition = removedPosition
        
        if removedPosition.rank == ranks - 1 { checkPosition.rank = ranks - 2 }
        if removedPosition.file == files - 1 { checkPosition.file = files - 2 }
        
        // Removed from bottom
        if removedPosition.rank == 0 {
            for file in squares {
                
                // Rank still has squares in it
                if file[0].state != .nonexistent {
                    return
                }
            }
            
            for (fileIndex, _) in squares.enumerated() {
                squares[fileIndex].remove(at: 0)
            }
            
            toggleBottomLeftSquareColor()
        }
        
        // Removed from top
        if removedPosition.rank == ranks - 1 {
            for file in squares {
                
                // Rank still has squares in it
                if file[ranks - 1].state != .nonexistent {
                    return
                }
            }
            
            for (fileIndex, _) in squares.enumerated() {
                squares[fileIndex].remove(at: ranks - 1)
            }
        }
        
        // Removed from left
        if removedPosition.file == 0 {
            if !squares[0].contains(where: { $0.state != .nonexistent }) {
                squares.remove(at: 0)
                toggleBottomLeftSquareColor()
            }
            
            
        }
        
        // Removed from right
        if removedPosition.file == files - 1 {
            print("removed from right")
            if !squares[files - 1].contains(where: { $0.state != .nonexistent }) {
                squares.remove(at: files - 1)
            }
        }
        
        // Something was removed
        updateSquarePositions(&squares)
        // Repeat until nothing else can be trimmed // TODO: Figure out how to accomplish this
        //trimSquaresIfNecessary(&squares, afterSquareRemovedAt: checkPosition)
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
        DragGesture()
			.updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
				gesturePanOffset = latestDragGestureValue.translation
			}
			.onEnded { finalDragGestureValue in
                // Quantize translation
                let translationX = (finalDragGestureValue.translation.width / sideLength).rounded() * sideLength
                let translationY = (finalDragGestureValue.translation.height / sideLength).rounded() * sideLength
                
                steadyStatePanOffset = steadyStatePanOffset + CGSize(width: translationX, height: translationY)//+ finalDragGestureValue.translation
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
