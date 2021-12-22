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
    //var changedGame: (Game) -> Void
    @StateObject var model: EditBoardViewModel
    
    @State var bottomLeftSquareColor: Square.SquareType = .dark
    @State var isDragEnabled: Bool = true
    
    init(game: Game, changedGame: @escaping (Game) -> Void) {
        self._game = State(wrappedValue: game)
        self._model = StateObject(wrappedValue: EditBoardViewModel(changedGame: changedGame))
    }
    
    private func toggleBottomLeftSquareColor() {
        if self.bottomLeftSquareColor == .light {
            self.bottomLeftSquareColor = .dark
        } else {
            self.bottomLeftSquareColor = .light
        }
        
        print("toggled to \(self.bottomLeftSquareColor)")
    }
	
//	var emptySquares: [[Square]] {
//        //let ranks = game.board.ranks + 2
//        //let files = game.board.files + 2
//        let emptyBoard = Board.empty(ranks: game.board.ranks + 2, files: game.board.files + 2, bottomLeftSquareColor: bottomLeftSquareColor)
//
//        //print("bot")
//
//		return emptyBoard.squares
//	}
    
    var emptyBoard: Board {
        return Board.empty(
            ranks: game.board.ranks + 2,
            files: game.board.files + 2,
            bottomLeftSquareColor: bottomLeftSquareColor
        )
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
                    BoardView2(
                        board: .constant(emptyBoard),
                        dragEnabled: isDragEnabled,
                        onSelected: { selectedPosition in
                            print("selected: \(selectedPosition)")
                            selectedPositionOnGhostBoard(selectedPosition, type: .light, sideLength: squareLength)
                        }
                    )
                        .opacity(0.2)
                        .frame(
                            width: squareLength * CGFloat(emptyBoard.files),
                            height: squareLength * CGFloat(emptyBoard.ranks)
                        )
                    
                    BoardView2(
                        board: $game.board,
                        dragEnabled: isDragEnabled,
                        pieceOpacity: isDragEnabled ? 1 : 0.4,
                        onSelected: { selectedPosition in
                            //print("game.board.squares: \(game.board.squares.flatMap { $0 }.count)")
                            //print("selectedPosition: \(selectedPosition)")
                            if gesturePanOffset == .zero {
                                selectedPositionOnBoard(selectedPosition, sideLength: squareLength)
                            }
                        },
                        onDrag: { (startingPosition, endingPosition) in
                            if let move = Move(start: startingPosition, end: endingPosition), game.board.squares[endingPosition]?.state != .nonexistent {
                                game.moveSetup(move)
                                //changedGame(game)
                                model.changedGame(game)
                                //print("move: \(move)")
                            }
                        }
                    )
                        .frame(
                            width: squareLength * CGFloat(game.board.files),
                            height: squareLength * CGFloat(game.board.ranks)
                        )
                        
                }
                .offset(x: -squareLength, y: squareLength)
                .offset(panOffset)
                .scaleEffect(zoomScale)
                //.animation(.easeInOut(duration: 0.05), value: panOffset)
                
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
            .gesture(!isDragEnabled ? panGesture(sideLength: squareLength) : nil)
            .gesture(!isDragEnabled ? zoomGesture() : nil)
            .toolbar {
                Button(isDragEnabled ? "Drag Board" : "Drag Pieces") {
                    isDragEnabled.toggle()
                }
            }
            .onAppear {
                // Find the square type
                let coloredSquareFile = game.board.squares.first(where: { $0.contains { $0.state != .nonexistent } })
                if let coloredSquare = coloredSquareFile?.first(where: { $0.state != .nonexistent }) {
                    let squaresAway = coloredSquare.position.rank + coloredSquare.position.file
                    if squaresAway % 2 == 0 {
                        bottomLeftSquareColor = coloredSquare.type
                    } else {
                        bottomLeftSquareColor = coloredSquare.type.opposite
                    }
                } else {
                    bottomLeftSquareColor = .dark
                }
                print("bottomLeftSquareColor: \(bottomLeftSquareColor)")
            }
        }
    }
    
    func selectedPositionOnBoard(_ selectedPosition: Position, sideLength: CGFloat) {
        print("selected: \(selectedPosition)")
        guard let square = game.board.squares[selectedPosition] else { return }
        if square.state == .empty {
            print("actuallySelected: \(selectedPosition)")
            game.board.squares[selectedPosition.file][selectedPosition.rank].state = .nonexistent
            
            // Remove row/file if there is nothing left in it and it's on the edge
            trimSquaresIfNecessary(afterSquareRemovedAt: selectedPosition, sideLength: sideLength)
        } else if square.state == .nonexistent {
            game.board.squares[selectedPosition.file][selectedPosition.rank].state = .empty
        }
        
        model.changedGame(game)
    }
	
    func selectedPositionOnGhostBoard(_ selectedPosition: Position, type: Square.SquareType, sideLength: CGFloat) {
		// Translate position to game board position
		var translatedPosition = Position(
			rank: selectedPosition.rank - 1,
			file: selectedPosition.file - 1
		)
        
        print("selected position: \(selectedPosition)")
		
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
                newFile.append(Square(state: state, position: position, type: type))
			}
			
			squares.insert(newFile, at: 0)
            //steadyStatePanOffset.width -= sideLength
            
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
                newFile.insert(Square(state: state, position: position, type: type), at: rank)
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
                let newSquare = Square(state: state, position: position, type: type)
                
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
                let newSquare = Square(state: state, position: position, type: type)
                
                //print("Added square: \(newSquare.state), to file: \(fileIndex), at: \(position)")
                
                //print("squares[\(fileIndex)]: \(squares[fileIndex].count)")
                squares[fileIndex].insert(newSquare, at: ranks)
                //print("squares[\(fileIndex)]: \(squares[fileIndex].count)")
            }
            isTranslatedPositionInBoard = false
            //steadyStatePanOffset.height -= sideLength
            
            //print("squares[0]: \(squares[0].count)")
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
            updateSquarePositions()
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
        
        model.changedGame(game)
	}
    
    private func updateSquarePositions() {
        print("updated square positions")
        // update all of the positions of all of the other squares
        for (fileIndex, file) in game.board.squares.enumerated() {
            for (rankIndex, _) in file.enumerated()
            {
                game.board.squares[fileIndex][rankIndex].position = Position(rank: rankIndex, file: fileIndex)
            }
        }
    }
    
    private func trimSquaresIfNecessary(afterSquareRemovedAt removedPosition: Position, sideLength: CGFloat) {
        
        // Position placed to collapse the board if an island is removed
        var checkPosition = removedPosition

        if removedPosition.rank == ranks - 1 { checkPosition.rank = ranks - 2 }
        if removedPosition.file == files - 1 { checkPosition.file = files - 2 }
        var removedSquare: Bool = false
        
        // Removed from bottom
        if removedPosition.rank == 0 {
            for file in game.board.squares {
                
                // Rank still has squares in it
                if file[0].state != .nonexistent {
                    return
                }
            }
            
            for (fileIndex, _) in game.board.squares.enumerated() {
                game.board.squares[fileIndex].remove(at: 0)
            }
            
            toggleBottomLeftSquareColor()
            removedSquare = true
        }
        
        // Removed from top
        if removedPosition.rank == ranks - 1 {
            for file in game.board.squares {
                
                // Rank still has squares in it
                if file[ranks - 1].state != .nonexistent {
                    return
                }
            }
            
            for (fileIndex, _) in game.board.squares.enumerated() {
                game.board.squares[fileIndex].remove(at: ranks - 1)
            }
            
            steadyStatePanOffset.height += sideLength
            removedSquare = true
        }
        
        // Removed from left
        if removedPosition.file == 0 {
            if !game.board.squares[0].contains(where: { $0.state != .nonexistent }) {
                game.board.squares.remove(at: 0)
                toggleBottomLeftSquareColor()
                
                steadyStatePanOffset.width += sideLength
                removedSquare = true
            }
        }
        
        // Removed from right
        if removedPosition.file == files - 1 {
            print("removed from right")
            if !game.board.squares[files - 1].contains(where: { $0.state != .nonexistent }) {
                game.board.squares.remove(at: files - 1)
                removedSquare = true
            }
        }
        
        updateSquarePositions()
        // Repeat until nothing else can be trimmed // TODO: Figure out how to accomplish this
        if removedSquare {
            // Something was removed
            trimSquaresIfNecessary(afterSquareRemovedAt: checkPosition, sideLength: sideLength)
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
	
    private func panGesture(sideLength: CGFloat) -> some Gesture {
        DragGesture()
			.updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
				gesturePanOffset = latestDragGestureValue.translation
			}
			.onEnded { finalDragGestureValue in
                // Quantize translation
//                let translationX = (finalDragGestureValue.predictedEndTranslation.width / sideLength).rounded() * sideLength
//                let translationY = finalDragGestureValue.predictedEndTranslation.height
                
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
