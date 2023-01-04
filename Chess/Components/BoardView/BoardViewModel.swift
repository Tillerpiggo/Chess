//
//  BoardViewModel.swift
//  Chess
//
//  Created by Tyler Gee on 8/25/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import SwiftUI

// Handles the BoardView - principally, translating a BoardModel into a usable Board for the view to read and render from, but also for other business logic
class BoardViewModel: ObservableObject {
    
    var board: Board {
        return boardBinding.wrappedValue
    }
    
    var boardBinding: Binding<Board>
    
    var files: Int { board.files }
    var ranks: Int { board.ranks }
    
    var cgFiles: CGFloat { CGFloat(files) }
    var cgRanks: CGFloat { CGFloat(ranks) }
    
    private var squareLength: CGFloat
    
    private var onSelected: (Position) -> Void
    private var onDrag: (Position, Position) -> Void
    private var onDrop: ([NSItemProvider], Position) -> Void
    //var updateIsDraggingPiece: (Bool) -> Void
    
    var size: CGSize {
        return CGSize(width: squareLength * CGFloat(cgFiles),
                      height: squareLength * CGFloat(cgRanks))
    }
    
    var squareSize: CGSize {
        return CGSize(width: squareLength, height: squareLength)
    }
    
    var pieceSize: CGSize {
        return squareSize * 0.9
    }
    
    // Size of dots that indicate legal moves
    var dotSize: CGSize {
        return squareSize * 0.3
    }
    
    var dragPieceSize: CGSize {
        return squareSize * 2
    }
    
    var circleSize: CGSize {
        return squareSize * 2 + CGSize(width: 16, height: 16)
    }
    
    func endingSquare(dragOffset: CGSize, startingPosition: Position) -> Square? {
        return board.squares[endingPosition(startingPosition: startingPosition, translation: dragOffset)]
    }
    
//    func onTouch(location: CGPoint, type: TouchLocatingView.TouchType, size: CGSize, selectedSquare: Binding<Square?>, dragPiece: Binding<Piece?>, touchDownPosition: Binding<Position?>) {
//        if type == .started {
//            touchDownPosition.wrappedValue = position(at: location, in: size)
//            selectedSquare.wrappedValue = board.squares[touchDownPosition.wrappedValue!] // force unwrap because it was just set
//            updateIsDraggingPiece(selectedSquare.wrappedValue?.piece != nil)
//            print("selectedSquare: \(selectedSquare.wrappedValue?.piece?.name)")
//            print("selectedSquarePiece: \(board.squares[touchDownPosition.wrappedValue!]?.piece?.name)")
//        } else if type == .ended {
//            let position = position(at: location, in: size)
//
//            if position == touchDownPosition.wrappedValue {
//                onSelected(position)
//            }
//
//            if dragPiece != nil {
//                // animate piece down
//            }
//
//            touchDownPosition.wrappedValue = nil
//            selectedSquare.wrappedValue = nil
//            dragPiece.wrappedValue = nil
//            print("drag piece nil")
//            updateIsDraggingPiece(false)
//        }
//    }
    
    func onDrop(providers: [NSItemProvider], location: CGPoint, size: CGSize) {
        let position = position(at: location, in: size)
        
        onDrop(providers, position)
    }
    
    func offset(for position: Position) -> CGSize {
        let width = CGFloat(position.file) * squareLength - (squareLength * cgFiles - squareLength) / 2
        let height = CGFloat(ranks - position.rank) * squareLength - (squareLength * cgRanks + squareLength) / 2
        
        return CGSize(width: width, height: height)
    }
    
    func pieceDragOffset(for position: Position, currentOffset: CGSize) -> CGSize {
        var offset = gestureDragOffset(for: position, currentOffset: currentOffset)
        offset.height -= 50
        
        return offset
    }
    
    func circleOffset(for position: Position, currentOffset: CGSize) -> CGSize {
        var offset = gestureDragOffset(for: position, currentOffset: currentOffset)
        offset.width /= squareLength
        offset.height /= squareLength
        
        if files % 2 == 0 {
            offset.width += 0.5
        }
        
        if ranks % 2 == 0 {
            offset.height += 0.5
        }
        
        offset.width = (offset.width).rounded() * squareLength
        offset.height = (offset.height).rounded() * squareLength
        
        if files % 2 == 0 {
            offset.width -= squareLength / 2.0
        }
        
        if ranks % 2 == 0 {
            offset.height -= squareLength / 2.0
        }
        
        return offset
    }
    
//    func dragPieceGesture(gestureDragOffset: GestureState<CGSize>, dragPiece: Binding<Piece?>, selectedSquare: Binding<Square?>) -> some Gesture {
//
//        let dragGesture = DragGesture(minimumDistance: 12)
//            .updating(gestureDragOffset) { latestDragGestureValue, pieceDragOffset, transaction in
//                pieceDragOffset = latestDragGestureValue.translation
//                print("ondrag pieceDragOffset: \(pieceDragOffset)")
//            }
//            .onChanged { latestDragGestureValue in
//                if let square = selectedSquare.wrappedValue {
//                    if dragPiece.wrappedValue == nil {
//                        print("dragpiece!")
//                        dragPiece.wrappedValue = square.piece
//                    }
//                }
//            }
//            .onEnded { finalDragGestureValue in
//                if let square = selectedSquare.wrappedValue, square.state != .nonexistent {
//                    print("onDrag!!!: \(finalDragGestureValue.translation)")
//                    self.onDrag(square.position, self.endingPosition(for: finalDragGestureValue.translation, startingPosition: square.position))
//                }
//
//                selectedSquare.wrappedValue = nil
//                dragPiece.wrappedValue = nil
//                print("drag piece nil")
//
//                self.updateIsDraggingPiece(false)
//            }
//
//        return dragGesture
//    }
    
    func onDrag(from startingPosition: Position, translation: CGSize) {
        onDrag(startingPosition, endingPosition(startingPosition: startingPosition, translation: translation))
    }
    
    private func gestureDragOffset(for position: Position, currentOffset: CGSize) -> CGSize {
        // First, offset so that the piece is at 0,0 (bottom left corner)
        var xOriginOffset = -1 * squareLength * (cgFiles / 2.0 - 0.5)
        var yOriginOffset = -1 * squareLength * (cgRanks / 2.0 - 0.5)
        
        // Transpose it to the desired square
        xOriginOffset += CGFloat(position.file) * squareLength
        yOriginOffset += CGFloat(position.rank) * squareLength
        
        return CGSize(
            width: currentOffset.width + xOriginOffset,
            height: currentOffset.height - yOriginOffset
        )
        
    }
    
    private func endingPosition(startingPosition: Position, translation: CGSize) -> Position {
        let finalDragLocation: (Int, Int) = location(for: translation, sideLength: squareLength)
        
        let endingPosition = Position(rank: startingPosition.rank + finalDragLocation.0, file: startingPosition.file + finalDragLocation.1)
        return endingPosition
    }
    
    func position(at location: CGPoint, in size: CGSize) -> Position {
        
        let file = position(
            tappedAt: location.x,
            divisions: files,
            length: squareLength * CGFloat(files),
            smallestSide: CGFloat(size.smallestSide))
        var rank = position(
            tappedAt: location.y,
            divisions: ranks,
            length: squareLength * CGFloat(ranks),
            smallestSide: CGFloat(size.smallestSide))
        rank = ranks - rank - 1
        
        return Position(rank: rank, file: file)
    }
    
    // Returns the position on the board, rank or file,
    // given the location in a certain dimension tapped, the number of divisions
    // along that dimension, the total length of the dimension,
    // and the length of the board that occupies that dimension
    private func position(tappedAt coordinate: CGFloat, divisions: Int, length: CGFloat, smallestSide: CGFloat) -> Int {
        // Transpose coordinate to the total length:
        
        // 1. Shift it so that it is centered
        let transposedCoordinate = coordinate
        
        // Calculate the position
        let position = Int(floor(Double(transposedCoordinate) * Double(divisions) / Double(length)))
        
        return position
    }
    
    private func location(for translation: CGSize, sideLength: CGFloat) -> (Int, Int) {
        let rank = Int((-1 * translation.height / sideLength + 0.5).rounded(.up) - 1)
        let file = Int((translation.width / sideLength + 0.5).rounded(.up) - 1)
        
        print("rank: \(rank)")
        
        return (rank, file)
    }
    
    init(board: Binding<Board>, squareLength: CGFloat, onSelected: @escaping (Position) -> Void, onDrag: @escaping (Position, Position) -> Void = { _, _ in }, onDrop: @escaping ([NSItemProvider], Position) -> Void) {
        self.boardBinding = board
        self.squareLength = squareLength
        
        self.onSelected = onSelected
        self.onDrag = onDrag
        self.onDrop = onDrop
    }
}
