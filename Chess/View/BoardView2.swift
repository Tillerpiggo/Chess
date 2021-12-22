//
//  BoardView2.swift
//  Chess
//
//  Created by Tyler Gee on 11/25/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

struct BoardView2: View {
    @Binding var board: Board
    var squareLength: CGFloat
    var dragEnabled: Bool
    var pieceOpacity: CGFloat
    var onSelected: (Position) -> Void = { _ in }
    var onDrag: (Position, Position) -> Void = { _, _ in }
    
    init(board: Binding<Board>,
         squareLength: CGFloat = 60,
         dragEnabled: Bool = true,
         pieceOpacity: CGFloat = 1.0,
         onSelected: @escaping (Position) -> Void = { _ in },
         onDrag: @escaping (Position, Position) -> Void = { _, _ in }) {
        self._board = board
        self.squareLength = squareLength
        self.dragEnabled = dragEnabled
        self.pieceOpacity = pieceOpacity
        self.onSelected = onSelected
        self.onDrag = onDrag
    }
    
    var size: CGSize {
        return CGSize(width: squareLength * CGFloat(board.files),
                      height: squareLength * CGFloat(board.ranks))
    }
    
    var pieces: [Piece] {
        var pieces = [Piece]()
        for file in board.squares {
            for square in file {
                if let piece = square.piece, piece.position != dragPiece?.position {
                    pieces.append(piece)
                }
            }
        }
        
        return pieces
    }
    
    @State var selectedSquare: Square? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let sideLength: CGFloat = geometry.size.smallestSide / CGFloat(board.smallestSide)
            
            ZStack {
                // The board
                Group {
                    BoardSquares(board, type: .light)
                        .fill(Color.lightSquareColor)
                    BoardSquares(board, type: .dark)
                        .fill(Color.darkSquareColor)
                }
                

                ForEach(pieces) { piece in
                    Image(piece.imageName)
                        .resizable()
                        .frame(
                            width: sideLength * 0.9,
                            height: sideLength * 0.9)
                        .offset(
                            x: CGFloat( piece.position.file) * sideLength - (geometry.size.smallestSide - sideLength) / 2,
                            y: CGFloat(board.ranks - piece.position.rank) * sideLength - (geometry.size.smallestSide + sideLength) / 2
                        )
                }
                .opacity(pieceOpacity)
                .animation(Animation.easeInOut(duration: 0.3), value: pieceOpacity)
                
                // The piece being dragged
                if let dragPiece = dragPiece {
                    if let selectedSquare = selectedSquare,
                       let square = board.squares[endingPosition(for: gestureDragOffset, sideLength: sideLength, startingPosition: selectedSquare.position)],
                       square.state != .nonexistent {
                        Group {
                            Rectangle()
                                .fill(Color.selectedSquareColor)
                                .frame(width: sideLength, height: sideLength)
                                .opacity(0.5)
                            Circle()
                                .fill(Color.black.opacity(0.2))
                                .frame(width: sideLength * 2 + 16, height: sideLength * 2 + 16)
                        }
                        .offset(circleDragOffset(sideLength: sideLength, position: dragPiece.position))
                    }
                    Image(dragPiece.imageName)
                        .resizable()
                        .frame(width: sideLength * 2, height: sideLength * 2)
                        .offset(pieceDragOffset(sideLength: sideLength, position: dragPiece.position))
                        
                }
                    
            }
            .onTouch(type: .startOrEnd, size: size) { location, type in
                if type == .started {
                    touchDownPosition = position(at: location, in: geometry.size)
                    selectedSquare = board.squares[touchDownPosition!] // force unwrap because it was just set
                } else if type == .ended {
                    let position = position(at: location, in: geometry.size)
                    if position == touchDownPosition {
                        onSelected(position)
                    }
                    touchDownPosition = nil;
                }
            }
            //.gesture(dragEnabled ? dragPieceGesture(sideLength: sideLength, square: selectedSquare) : nil)
            
        }
    }
    // Make sure that dragging doesn't trigger tapping on the ghost board
    
    @State private var touchDownPosition: Position?
    
    // MARK: - Drag Piece Gesture
    @GestureState private var gestureDragOffset: CGSize = .zero
    @GestureState private var canPlaceDragPiece: Bool = true
    @State private var dragPiece: Piece? = nil
    @State private var dragPieceStartingLocation: CGSize = .zero
    
    private func dragPieceGesture(sideLength: CGFloat, square: Square?) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($gestureDragOffset) { latestDragGestureValue, pieceDragOffset, transaction in
                pieceDragOffset = latestDragGestureValue.translation
            }
            .onChanged { latestDragGestureValue in
                if let square = square {
                    if dragPiece == nil {
                        dragPiece = square.piece
                    }
                }
            }
            .onEnded { finalDragGestureValue in
                if let square = square, square.state != .nonexistent {
                    print("onDrag!!!")
                    onDrag(square.position, endingPosition(for: finalDragGestureValue.translation, sideLength: sideLength, startingPosition: square.position))
                }
                
                selectedSquare = nil
                dragPiece = nil
            }
    }
    
    private func endingPosition(for translation: CGSize, sideLength: CGFloat, startingPosition: Position) -> Position {
        let finalDragLocation: (Int, Int) = location(for: translation, sideLength: sideLength)
//        if isReversed {
//            finalDragLocation.0 *= -1
//            finalDragLocation.1 *= -1
//        }
        
        let endingPosition = Position(rank: startingPosition.rank + finalDragLocation.0, file: startingPosition.file + finalDragLocation.1)
        return endingPosition
    }
    
    private func location(for translation: CGSize, sideLength: CGFloat) -> (Int, Int) {
        let rank = Int((-1 * translation.height / sideLength + 0.5).rounded(.up) - 1)
        let file = Int((translation.width / sideLength + 0.5).rounded(.up) - 1)
        
        print("rank: \(rank)")
        
        return (rank, file)
    }
    
    private func gestureDragOffset(sideLength: CGFloat, position: Position) -> CGSize {
        // First, offset so that the piece is at 0,0 (bottom left corner)
        var xOriginOffset = -1 * sideLength * (CGFloat(board.files) / 2.0 - 0.5)
        var yOriginOffset = -1 * sideLength * (CGFloat(board.ranks) / 2.0 - 0.5)
        
        // Transpose it to the desired square
        xOriginOffset += CGFloat(position.file) * sideLength
        yOriginOffset += CGFloat(position.rank) * sideLength
        
        // Adjust for custom dimensions
//        let xOffset = CGFloat(board.files - board.smallestSide) * sideLength * 0.5
//        let yOffset = CGFloat(board.ranks - board.smallestSide) * sideLength * 0.5
//        xOriginOffset += xOffset
//        yOriginOffset -= yOffset
        
        print("ranks: \(board.ranks) (BoardView)")
        print("files: \(board.files) (BoardView)")
        
        
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
//        offset.width = (offset.width / sideLength - 0.5).rounded(.up) * sideLength //- sideLength / 2
//        offset.height = (offset.height / sideLength - 0.5).rounded(.up) * sideLength //- sideLength / 2
        offset.width /= sideLength
        offset.height /= sideLength
        
        print("ranks: \(board.ranks), files: \(board.files)")
        
        if board.files % 2 == 0 || board.ranks % 2 == 0 || true {
            offset.width += 0.5
            offset.height += 0.5
        }
        
        offset.width = (offset.width).rounded() * sideLength
        offset.height = (offset.height).rounded() * sideLength
        
        if board.files % 2 == 0 || board.ranks % 2 == 0 || true {
            offset.width -= sideLength / 2.0
            offset.height -= sideLength / 2.0
        }
        
        return offset
    }
    
    private func position(at location: CGPoint, in size: CGSize) -> Position {
        print("width: \(size.width), height: \(size.height)")
        print("largestSide: \(size.largestSide)")
        
        print("file: ")
        let file = position(
            tappedAt: location.x,
            divisions: board.files,
            length: size.width,
            smallestSide: CGFloat(size.smallestSide))
        print("rank: ")
        var rank = position(
            tappedAt: location.y,
            divisions: board.ranks,
            length: size.height,
            smallestSide: CGFloat(size.smallestSide))
        rank = board.ranks - rank - 1
        
        print("")
        
        return Position(rank: rank, file: file)
    }
    
    // TODO: describe this method better and use better argument names
    
    // Returns the position on the board, rank or file,
    // given the location in a certain dimension tapped, the number of divisions
    // along that dimension, the total length of the dimension,
    // and the length of the board that occupies that dimension
    private func position(tappedAt coordinate: CGFloat, divisions: Int, length: CGFloat, smallestSide: CGFloat) -> Int {
        // Transpose coordinate to the total length:
        
        // 1. Shift it so that it is centered
        let transposition = (length - smallestSide) / 2 // partial length is centered in total length
        print("transposition: \(transposition)")
        let transposedCoordinate = coordinate// - transposition// - transpositionDownwards
        
        print("transposed: \(transposedCoordinate)")
        
        // Calculate the position
        let position = Int(floor(Double(transposedCoordinate) * Double(divisions) / Double(length)))
        
        return position
    }
    
    
}


struct BoardSquares: Shape {
    var board: Board
    
    // If this is .light, returns the path for all of the light squares
    // (top-left square is light)
    // Otherwise, returns the path of all other (dark) squares
    var type: BoardType
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let sideLength = rect.size.smallestSide / CGFloat(board.smallestSide)
        
        for file in 0..<board.files {
            for rank in 0..<board.ranks {
                // To center the board
                let xOffset: CGFloat = (rect.size.width - rect.size.smallestSide) / 2
                let yOffset: CGFloat = (rect.size.height - rect.size.smallestSide) / 2
                
                // Only do light squares if it is light
                // Otherwise only do dark squares
                if ((file + rank) % 2 == 0) == (type == .light) {
                    let rect = CGRect(x: sideLength * CGFloat(file) + xOffset,
                                      y: sideLength * CGFloat(board.ranks - rank - 1) + yOffset,
                                      width: sideLength,
                                      height: sideLength)
                    if (board.squares[file][rank].state != .nonexistent) {
                        path.addRect(rect)
                    }
                }
            }
        }
        
        return path
    }
    
    enum BoardType {
        case light, dark
    }
    
    init(_ board: Board, type: BoardType) {
        self.board = board
        self.type = type
    }
}

struct BoardView2_Previews: PreviewProvider {
    static var previews: some View {
        BoardView2(board: .constant(Game.standard().board))
    }
}
