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
    var selectedSquares: [Position]
    var legalMoves: [Position]
    var selectionColor: Color
    var bottomLeftSquareColor: Square.SquareType
    var squareLength: CGFloat
    var cornerRadius: CGFloat
    var pieceOpacity: CGFloat
    var onSelected: (Position) -> Void = { _ in }
    var onDrag: (Position, Position) -> Void = { _, _ in }
    var onDrop: ([NSItemProvider], Position) -> Void = { _, _ in }
    var updateIsDraggingPiece: (Bool) -> Void
    
    init(board: Binding<Board>,
         selectedSquares: [Position] = [],
         legalMoves: [Position] = [],
         selectionColor: Color = .selectedSquareColor,
         bottomLeftSquareColor: Square.SquareType? = nil,
         squareLength: CGFloat = 60,
         cornerRadius: CGFloat = 0,
         pieceOpacity: CGFloat = 1.0,
         onSelected: @escaping (Position) -> Void = { _ in },
         onDrag: @escaping (Position, Position) -> Void = { _, _ in },
         onDrop: @escaping ([NSItemProvider], Position) -> Void = { _, _ in },
         updateIsDraggingPiece: @escaping (Bool) -> Void = { _ in })
    {
        self._board = board
        self.selectedSquares = selectedSquares
        self.legalMoves = legalMoves
        self.selectionColor = selectionColor
        self.bottomLeftSquareColor = bottomLeftSquareColor ?? board.wrappedValue.bottomLeftSquareColor
        self.squareLength = squareLength
        self.cornerRadius = cornerRadius
        self.pieceOpacity = pieceOpacity
        self.onSelected = onSelected
        self.onDrag = onDrag
        self.onDrop = onDrop
        self.updateIsDraggingPiece = updateIsDraggingPiece
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
            //let sideLength: CGFloat = geometry.size.smallestSide / CGFloat(board.smallestSide)
            
            ZStack {
                // The board
                Group {
                    BoardSquares(board, type: .light)
                        .fill(bottomLeftSquareColor == .dark ? Color.lightSquareColor : Color.darkSquareColor)
                    BoardSquares(board, type: .dark)
                        .fill(bottomLeftSquareColor == .dark ? Color.darkSquareColor : Color.lightSquareColor)
                }
                .cornerRadius(cornerRadius)
                .drawingGroup()
                
                ForEach(selectedSquares.compactMap { $0 }, id: \.self) { position in
                    Rectangle()
                        .fill(selectionColor)
                        .opacity(0.5)
                        .frame(width: squareLength, height: squareLength)
                        .offset(
                            x: CGFloat(position.file) * squareLength - (squareLength * CGFloat(board.files) - squareLength) / 2,
                            y: CGFloat(board.ranks - position.rank) * squareLength - (squareLength * CGFloat(board.ranks) + squareLength) / 2
                        )
                }
                
                ForEach(legalMoves.compactMap { $0 }, id: \.self) { position in
                    Circle()
                        .fill(.black.opacity(0.2))
                        .frame(width: squareLength * 0.3, height: squareLength * 0.3)
                        .offset(
                            x: CGFloat(position.file) * squareLength - (squareLength * CGFloat(board.files) - squareLength) / 2,
                            y: CGFloat(board.ranks - position.rank) * squareLength - (squareLength * CGFloat(board.ranks) + squareLength) / 2
                        )
                }
                
                if let selectedSquare = selectedSquare,
                   let square = board.squares[endingPosition(for: gestureDragOffset, sideLength: squareLength, startingPosition: selectedSquare.position)],
                   square.state != .nonexistent, selectedSquare.piece != nil {
                    Group {
                        Rectangle()
                            .fill(Color.selectedSquareColor)
                            .frame(width: squareLength, height: squareLength)
                            .opacity(0.5)
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: squareLength * 2 + 16, height: squareLength * 2 + 16)
//                                    .transition(
//                                        AnyTransition.scale(scale: 0.0).combined(with:
//                                                                                AnyTransition.offset(circleDragOffset(sideLength: squareLength, position: dragPiece.position)))
//                                    )
                    }
                    .offset(circleDragOffset(sideLength: squareLength, position: selectedSquare.position))
                }

                ForEach(pieces, id: \.position) { piece in
                    Image(piece.imageName)
                        .resizable()
                        .frame(
                            width: squareLength * 0.9,
                            height: squareLength * 0.9)
                        .offset(
                            x: CGFloat(piece.position.file) * squareLength - (squareLength * CGFloat(board.files) - squareLength) / 2,
                            y: CGFloat(board.ranks - piece.position.rank) * squareLength - (squareLength * CGFloat(board.ranks) + squareLength) / 2
                        )
                        .transition(.opacity)
                }
                .opacity(pieceOpacity)
                .animation(Animation.easeInOut(duration: 0.3), value: pieceOpacity)
                
                // The piece being dragged
                    
                    
                if let dragPiece = dragPiece {
                    Image(dragPiece.imageName)
                        .resizable()
                        .frame(width: squareLength * 2, height: squareLength * 2)
                        .offset(pieceDragOffset(sideLength: squareLength, position: dragPiece.position))
                        .transition(
                            AnyTransition.scale(scale: 0.0).combined(with:
                                                                    AnyTransition.offset(circleDragOffset(sideLength: squareLength, position: dragPiece.position)))
                        )
                        .animation(.interactiveSpring(), value: gestureDragOffset)
                }
                //.animation(.default, value: dragPiece)
                    
            }
            .frame(width: squareLength * CGFloat(board.files), height: squareLength * CGFloat(board.ranks))
            .onTouch(type: .startOrEnd) { location, type in
                if type == .started {
                    touchDownPosition = position(at: location, in: geometry.size, ranks: board.ranks, files: board.files)
                    selectedSquare = board.squares[touchDownPosition!] // force unwrap because it was just set
                    updateIsDraggingPiece(selectedSquare?.piece != nil)
                    
//                    if let square = selectedSquare {
//                        if dragPiece == nil {
//                            // animate piece up
//                            //withAnimation(.spring()) {
//                                dragPiece = square.piece
//                            //}
//                        }
//                    }
                    if let position = touchDownPosition {
                        onSelected(position)
                    }
                } else if type == .ended {
                    let position = position(at: location, in: geometry.size, ranks: board.ranks, files: board.files)
                    print("selectedPosition (BoardView): \(position)")
                    if position == touchDownPosition {
                        onSelected(position)
                    }
                    touchDownPosition = nil
                    if dragPiece != nil {
                        // animate piece down
                    }
                    
                    
                    selectedSquare = nil
                    dragPiece = nil
                    updateIsDraggingPiece(false)
                }
            }
            .onDrop(of: ["public.text"], isTargeted: nil, perform: { providers, location in
                let position = position(at: location, in: geometry.size, ranks: board.ranks, files: board.files)
                
                onDrop(providers, position)
                print("You dropped something!")
                return true
            })
            .gesture(dragPieceGesture(sideLength: squareLength))
        }
    }
    // Make sure that dragging doesn't trigger tapping on the ghost board
    
    @State private var touchDownPosition: Position?
    
    // MARK: - Drag Piece Gesture
    @GestureState private var gestureDragOffset: CGSize = .zero
    @GestureState private var canPlaceDragPiece: Bool = true
    @State private var dragPiece: Piece? = nil
    
    private func dragPieceGesture(sideLength: CGFloat) -> some Gesture {
        
        // TODO: make this gesture faster. Right now, it makes the overall dragging laggy
        let dragGesture = DragGesture(minimumDistance: 12)
            .updating($gestureDragOffset) { latestDragGestureValue, pieceDragOffset, transaction in
                pieceDragOffset = latestDragGestureValue.translation
                print("ondrag pieceDragOffset: \(pieceDragOffset)")
            }
            .onChanged { latestDragGestureValue in
                if let square = selectedSquare {
                    if dragPiece == nil {
                        dragPiece = square.piece
                    }
                }
            }
            .onEnded { finalDragGestureValue in
                if let square = selectedSquare, square.state != .nonexistent {
                    print("onDrag!!!: \(finalDragGestureValue.translation)")
                    onDrag(square.position, endingPosition(for: finalDragGestureValue.translation, sideLength: sideLength, startingPosition: square.position))
                }
                
                selectedSquare = nil
                dragPiece = nil
                
                updateIsDraggingPiece(false)
            }
        
        return dragGesture
        //return longPressGesture.sequenced(before: dragGesture)//LongPressGesture(minimumDuration: 0.1).sequenced(before: dragGesture)
    }
    
    private func endingPosition(for translation: CGSize, sideLength: CGFloat, startingPosition: Position) -> Position {
        let finalDragLocation: (Int, Int) = location(for: translation, sideLength: sideLength)
        
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
        
        return CGSize(
            width: gestureDragOffset.width + xOriginOffset,
            height: gestureDragOffset.height - yOriginOffset
        )
        
    }
    
    // Offsets pieceDragOffset for visual display
    private func pieceDragOffset(sideLength: CGFloat, position: Position) -> CGSize {
        // Place it above the finger
        var offset = gestureDragOffset(sideLength: sideLength, position: position)
        offset.height -= 50
        
        return offset
    }
    
    private func circleDragOffset(sideLength: CGFloat, position: Position) -> CGSize {
        var offset = gestureDragOffset(sideLength: sideLength, position: position)
//        offset.width = (offset.width / sideLength - 0.5).rounded(.up) * sideLength //- sideLength / 2
//        offset.height = (offset.height / sideLength - 0.5).rounded(.up) * sideLength //- sideLength / 2
        offset.width /= sideLength
        offset.height /= sideLength
        
        print("ranks: \(board.ranks), files: \(board.files)")
        
        if board.files % 2 == 0 {
            offset.width += 0.5
        }
        
        if board.ranks % 2 == 0 {
            offset.height += 0.5
        }
        
        offset.width = (offset.width).rounded() * sideLength
        offset.height = (offset.height).rounded() * sideLength
        
        if board.files % 2 == 0 {
            offset.width -= sideLength / 2.0
        }
        
        if board.ranks % 2 == 0 {
            offset.height -= sideLength / 2.0
        }
        
        return offset
    }
    
    private func position(at location: CGPoint, in size: CGSize, ranks: Int, files: Int) -> Position {
        //print("width: \(size.width), height: \(size.height)")
        //print("largestSide: \(size.largestSide)")
        
       // print("file: ")
        let file = position(
            tappedAt: location.x,
            divisions: files,
            length: squareLength * CGFloat(files),
            smallestSide: CGFloat(size.smallestSide))
        //print("rank: ")
        var rank = position(
            tappedAt: location.y,
            divisions: ranks,
            length: squareLength * CGFloat(ranks),
            smallestSide: CGFloat(size.smallestSide))
        rank = ranks - rank - 1
        
        //print("")
        
        print("BoardView ranks: \(ranks) (BoardView)")
        print("BoardView files: \(files) (BoardView)")
        
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
        print("transdivisions: \(divisions)")
        print("translength: \(length)")
        
        // Calculate the position
        let position = Int(floor(Double(transposedCoordinate) * Double(divisions) / Double(length)))
        print("trans POSItion: \(position)")
        
        return position
    }
    
    
}

// MARK: - Board Squares
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
                //let xOffset: CGFloat = (rect.size.width - rect.size.smallestSide) / 2
                //let yOffset: CGFloat = (rect.size.height - rect.size.smallestSide) / 2
                
                // Only do light squares if it is light
                // Otherwise only do dark squares
                if ((file + rank) % 2 == 0) == (type == .light) {
                    let rect = CGRect(x: sideLength * CGFloat(file),// + xOffset,
                                      y: sideLength * CGFloat(board.ranks - rank - 1),// + yOffset,
                                      width: sideLength,
                                      height: sideLength)
                    if (board.squares[file][rank].state != .nonexistent) {
                        path.addRect(rect)
                    }
                }
            }
        }
        
        print("path ranks: \(board.ranks), files: \(board.files)")
        
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
        BoardView2(board: .constant(Game.standard().board), bottomLeftSquareColor: .dark)
    }
}
