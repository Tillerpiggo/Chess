//
//  BoardView.swift
//  Chess
//
//  Created by Tyler Gee on 2/8/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct BoardView: View {
	// It is assumed/expected that this array represents a rectangle (all inner lists have the same length)
	
	@Binding var squares: [[Square]]
	var squareLength: CGFloat?
	var selectedSquares: [Position]
	var legalMoves: [Position]
	var onSelected: (Position) -> Void = { _ in }
    
    // Very stupid very dumb workaround
    struct File: Identifiable, Hashable {
        var id = UUID()
        var squares: [Square]
        
        init(_ squares: [Square]) {
            self.squares = squares
        }
    }
    
    private var fileList: [File] { squares.map { File($0) } }
	
	
	// StartingPosition, EndingPosition
	var onDrag: (Position, Position) -> Void = { _, _ in }
	
	// Providers, rank, file
	var onDrop: ([NSItemProvider], Int, Int) -> Void = { _, _, _ in }
	
	
	var makeSelectedSquaresRed = false
	
	private var ranks: Int {
		return squares.first?.count ?? 0
	}
	
	private var files: Int {
		return squares.count
	}
    
    private var squareList: [Square] { squares.flatMap { $0 }}
    
    private func xOffset(for square: Square, sideLength: CGFloat) -> CGFloat { (CGFloat(square.position.file) - CGFloat(files / 2)) * sideLength }
    private func yOffset(for square: Square, sideLength: CGFloat) -> CGFloat { (CGFloat(square.position.rank) - CGFloat(ranks / 2)) * sideLength }
	
    private var columns: [GridItem] {
        return [GridItem](repeating: GridItem(.flexible()), count: 8)
    }
    
    @State var selectedSquare: Square? = nil
    
	var body: some View {
		GeometryReader { geometry in
			let sideLength = squareLength ?? CGFloat(geometry.size.smallestSide) / CGFloat(squares.largestDimension)
			ZStack {
				HStack(spacing: 0) {
                    ForEach(fileList, id: \.self) { (file) in
                        VStack(spacing: 0) {
                            ForEach(file.squares.reversed(), id: \.self) { square in
//                                if square.piece != nil {
//                                    self.square(square, sideLength: sideLength)
//                                            .onTapGesture { onSelected(square.position) }
//                                            //.gesture(dragPieceGesture(sideLength: sideLength, square: squares[square.position.file][square.position.rank]))
//                                } else {
//                                    self.square(square, sideLength: sideLength)
//                                        .onTapGesture { onSelected(square.position) }
//                                }
                                if square.piece != nil {
                                    self.square(square, sideLength: sideLength)
                                        .gesture(LongPressGesture()
                                                    .onChanged { _ in
                                                        self.selectedSquare = square
                                                        print("Selected Square: \(square.position)")
                                                    }
                                                    .onEnded { _ in
                                                        self.selectedSquare = nil
                                                        self.dragPiece = nil
                                                    }
                                        )
                                        //.onTapGesture { onSelected(square.position) }
                                } else {
                                    self.square(square, sideLength: sideLength)
                                        .highPriorityGesture(TapGesture()
                                                                .onEnded() {
                                            onSelected(square.position)
                                        })
                                }

                            }
                            //fileView(file, sideLength: sideLength)
                            //square(file.squares[0], sideLength: sideLength)
                        }
                        .frame(width: sideLength)
					}
				}
                .gesture(dragPieceGesture(sideLength: sideLength, square: selectedSquare))
                .drawingGroup()
                 
            
//                HStack(spacing: 0) {
//                    ForEach(0..<squares.count) { (file) in
//                        VStack(spacing: 0) {
//                            ForEach((0..<squares[file].count).reversed(), id: \.self) { (rank) in
//                                if squares[file][rank].piece != nil {
//                                    square(squares[file][rank], sideLength: sideLength)
//                                        .onTapGesture { onSelected(Position(rank: rank, file: file)) }
//                                        .gesture(dragPieceGesture(sideLength: sideLength, square: squares[file][rank]))
//                                } else {
//                                    square(squares[file][rank], sideLength: sideLength)
//                                        .onTapGesture { onSelected(Position(rank: rank, file: file)) }
//                                }
//                            }
//                        }
//                        .frame(width: sideLength)
//                    }
//                }
//                .frame(width: geometry.size.width, height: geometry.size.height)
                
				
				// Drag piece
				if let dragPiece = dragPiece {
					Circle()
						.fill(Color.black.opacity(0.2))
						.frame(width: sideLength * 2 + 16, height: sideLength * 2 + 16)
						.offset(circleDragOffset(sideLength: sideLength, position: dragPiece.position))
					Image(dragPiece.imageName)
						.resizable()
						.frame(width: sideLength * 2, height: sideLength * 2)
						.offset(pieceDragOffset(sideLength: sideLength, position: dragPiece.position))
				}
				
				
			}
		}
	}
    
    
	
	
	private func gestureDragOffset(sideLength: CGFloat, position: Position) -> CGSize {
		// First, offset so that the piece is at 0,0 (bottom left corner)
		var xOriginOffset = -1 * sideLength * (CGFloat(files) / 2.0 - 0.5)
		var yOriginOffset = -1 * sideLength * (CGFloat(ranks) / 2.0 - 0.5)
		
		// Transpose it to the desired square
		xOriginOffset += CGFloat(position.file) * sideLength
		yOriginOffset += CGFloat(position.rank) * sideLength
		
		return CGSize(
			width: gestureDragOffset.width + xOriginOffset,
			height: gestureDragOffset.height - yOriginOffset
		)
		
	}
	
	// Offsets pieceDragOffset for visual display
	private func pieceDragOffset(sideLength: CGFloat, position: Position) -> CGSize {
		// Place it above the finger
		var offset = gestureDragOffset(sideLength: sideLength, position: position)
		offset.height -= 40
		
		return offset
	}
	
	private func circleDragOffset(sideLength: CGFloat, position: Position) -> CGSize {
		var offset = gestureDragOffset(sideLength: sideLength, position: position)
		
		// Quantize values to grid (TODO figure out quantization for dynamic boards)
		//offset.width = ((offset.width / sideLength + 0.5).rounded()) * sideLength - sideLength / 2.0
		//offset.height = ((offset.height / sideLength + 0.5).rounded()) * sideLength - sideLength / 2.0
		
		return offset
	}
    
    private func square(_ square: Square, sideLength: CGFloat) -> some View {
        ZStack { // To make the inner view update (dunno why this works)
           let showPiece = !((square.position.rank == dragPiece?.position.rank) && (square.position.file == dragPiece?.position.file))
            
            SquareView(square, isSelected: selectedSquares.contains(Position(rank: square.position.rank, file: square.position.file)), isRed: makeSelectedSquaresRed, showPiece: showPiece)
                .frame(width: sideLength, height: sideLength)
                .onDrop(of: ["public.text"], isTargeted: nil) { providers, _ in
                    onDrop(providers, square.position.rank, square.position.file)
                    return true
                }
            
            if legalMoves.contains(Position(rank: square.position.rank, file: square.position.file)) {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
	
	private func square(rank: Int, file: Int, sideLength: CGFloat) -> some View {
		ZStack { // To make the inner view update (dunno why this works)
			let showPiece = !((rank == dragPiece?.position.rank) && (file == dragPiece?.position.file))
			
			SquareView(squares[file][rank], isSelected: selectedSquares.contains(Position(rank: rank, file: file)), isRed: makeSelectedSquaresRed, showPiece: showPiece)
				.frame(width: sideLength, height: sideLength)
				/*
				.onTapGesture {
					onSelected(Position(rank: rank, file: file))
				}
*/
				.onDrop(of: ["public.text"], isTargeted: nil) { providers, _ in
					onDrop(providers, rank, file)
					return true
				}
			
			if legalMoves.contains(Position(rank: rank, file: file)) {
				Circle()
					.fill(Color.black.opacity(0.3))
					.frame(width: 8, height: 8)
			}
		}
	}
	
	@GestureState private var gestureDragOffset: CGSize = .zero
	@State private var dragPiece: Piece? = nil
	@State private var dragPieceStartingLocation: CGSize = .zero
	
	private func dragPieceGesture(sideLength: CGFloat, square: Square?) -> some Gesture {
		DragGesture(minimumDistance: 0)
			.updating($gestureDragOffset) { latestDragGestureValue, pieceDragOffset, transaction in
                if let square = square {
                    print("pieceDragOffset: \(pieceDragOffset)")
                    pieceDragOffset = latestDragGestureValue.translation
                }
			}
			.onChanged { _ in
                if let square = square {
                    if dragPiece == nil {
                        dragPiece = square.piece
                    }
                }
			}
			.onEnded { finalDragGestureValue in
                print("ended")
                
                if let square = square, square.state != .nonexistent {
                    let finalDragLocation: (Int, Int) = location(for: finalDragGestureValue.translation, sideLength: sideLength)
                    let startingPosition = square.position
                    let endingPosition = Position(rank: startingPosition.rank + finalDragLocation.0, file: startingPosition.file + finalDragLocation.1)
                    
                    
                    onDrag(startingPosition, endingPosition)
                }
				
                dragPiece = nil
			}
	}
	
	private func location(for translation: CGSize, sideLength: CGFloat) -> (Int, Int) {
        let rank = Int((-1 * translation.height / sideLength + 0.5).rounded(.up) - 1)
        let file = Int((translation.width / sideLength + 0.5).rounded(.up) - 1)
		
		print("rank: \(rank)")
		
		return (rank, file)
	}
	
	private func location(for translation: CGPoint, sideLength: CGFloat) -> (Int, Int) {
		return location(for: CGSize(width: translation.x, height: translation.y), sideLength: sideLength)
	}
	
	private func squareSideLength(in geometry: GeometryProxy) -> CGFloat {
		var sideLength: CGFloat
		
		if geometry.size.width < geometry.size.height {
			sideLength = geometry.size.width / CGFloat(squares.count) // divide by the number of files
		} else {
			sideLength = geometry.size.width / CGFloat(squares[0].count) // divide by the number of ranks (assumed to be the same for each rank)
		}
		
		print(sideLength)
		
		return sideLength
	}
}

struct SquareView: View {
	var square: Square
	var isSelected: Bool
	var isRed: Bool
	var showPiece: Bool
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Rectangle()
					.fill(square.type == .light ? Color.lightSquareColor : Color.darkSquareColor)
				
				if isSelected {
					Rectangle()
						.fill(isRed ? Color.red : Color.selectedSquareColor)
						.opacity(0.5)
				}
				
				if square.piece != nil && showPiece {
					Image(square.piece!.imageName)
						.resizable()
						.frame(width: geometry.size.width - 4, height: geometry.size.height - 4)
				}
			}
			.opacity(square.state == .nonexistent ? 0 : 1)
		}
	}
	
	/*
	var color: Color {
		var color: Color = square.type == .light ? .lightSquareColor : .darkSquareColor
		if isSelected { color = .selectedSquareColor }
		
		//print("color: \(color)")
		return color
	}
*/
	
	init(_ square: Square, isSelected: Bool, isRed: Bool, showPiece: Bool = true) {
		self.square = square
		self.isSelected = isSelected
		self.isRed = isRed
		self.showPiece = showPiece
	}
}
