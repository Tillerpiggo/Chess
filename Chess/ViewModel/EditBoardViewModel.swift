////
////  EditBoardViewModel.swift
////  Chess
////
////  Created by Tyler on 10/31/21.
////  Copyright © 2021 Beaglepig. All rights reserved.
////


import SwiftUI

class EditBoardViewModel: ObservableObject {
    var bottomLeftSquareColor: Square.SquareType {
        return game.board.squares[Position(rank: 0, file: 0)]?.type ?? .dark
    }
    
    var changedGame: (Game) -> Void
    
    @Published var game: Game
    private var ranks: Int { game.board.squares.first?.count ?? 0 }
    private var files: Int { game.board.squares.count }
    
    @Published var selectedPlayer: Player = .white
    
    @Published var selectedPiece: UUID?
    
    @Published var emptyBoard: Board
    
    var pieces: [Piece] {
        if selectedPlayer == .white {
            return game.pieces
        } else {
            return game.pieces.map { piece in
                var blackPiece = piece
                blackPiece.owner = .black
                return blackPiece
            }
        }
    }
    
    func selectedPiece(_ piece: Piece) {
        if selectedPiece == piece.id {
            selectedPiece = nil
        } else {
            selectedPiece = piece.id
        }
    }
    
    func onDrag(from startingPosition: Position, to endingPosition: Position) {
        if let move = Move(start: startingPosition, end: endingPosition), game.board.squares[endingPosition]?.state != .nonexistent {
            game.moveSetup(move)
            changedGame(game)
        }
    }
    
    /// Selects the position on the board. If the square has a piece, does nothing. Otherwise, toggles
    /// The existence of the square on/off.
    /// Returns a Position corresponding to the direction the square was removed (0, 0) if it wasn't
    /// (rank, file): (1, 1) would be the top right
    func selectedPositionOnBoard(_ selectedPosition: Position) -> Position {
        var directionRemoved = Position(rank: 0, file: 0)
        
        //print("selectedPosition")
        if let square = game.board.squares[selectedPosition] {
            if let selectedPiece = selectedPiece {
                
                if square.piece?.id == selectedPiece && square.piece?.owner == selectedPlayer {
                    game.board.squares[selectedPosition]?.setStartingPiece(nil)
                } else {
                    var piece = piece(selectedPiece.uuidString)!
                    piece.owner = selectedPlayer
                    game.board.squares[selectedPosition]?.setStartingPiece(piece)
                }
            } else {
                if square.state == .empty {
                    game.board.squares[selectedPosition]?.state = .nonexistent
                } else if square.state == .nonexistent {
                    game.board.squares[selectedPosition]?.state = .empty
                }

                //directionRemoved = trimSquaresIfNecessary(afterSquareRemovedAt: selectedPosition, sideLength: sideLength)
                directionRemoved = trimSquaresIfNecessary()
                updateSquarePositions()
            }
            
            changedGame(game)
            updateEmptyBoard()
            //print("... and changed the game")
        } else {
            // since the method is designed for a tap on the ghost board itself, "unmodify" the position
            let translatedPosition = Position(
                rank: selectedPosition.rank + 1,
                file: selectedPosition.file + 1)
            selectedPositionOnGhostBoard(translatedPosition)
            fatalError()
        }
        
        return directionRemoved
    }
    
    private func piece(_ id: String) -> Piece? {
        return game.pieces.first(where: { $0.id.uuidString == id })
    }
    
    /// Selects the position on the ghost board. This should add a square
    /// at the position tapped.
    /// Returns a Position corresponding to the direction the square was added ((rank, file))
    /// (-1, -1) would be the bottom left, (1, 1) would be the top right, (-1, 0) would be the bottom
    func selectedPositionOnGhostBoard(_ selectedPosition: Position) -> Position {
        // Translate the position to the position on the actual board
        var translatedPosition = Position(
            rank: selectedPosition.rank - 1,
            file: selectedPosition.file - 1)
        //let translatedPosition = selectedPosition
        let type = emptyBoard.squares[selectedPosition]!.type// ?? .dark
        print("selected ghost board at rank: \(translatedPosition.rank), file: \(translatedPosition.file)")
        
        var directionAdded = Position(rank: 0, file: 0)
        
        let bottomRank = 0
        let topRank = ranks - 1
        let leftmostFile = 0
        let rightmostFile = files - 1
        
        // Tapped on the left
        if translatedPosition.file < leftmostFile {
            insertFile(at: leftmostFile, selectedPosition: translatedPosition.rank, selectedType: type)
            translatedPosition.file += 1
            directionAdded.file = -1
        }
        
        // Tapped on the right
        if translatedPosition.file > rightmostFile {
            insertFile(at: rightmostFile + 1, selectedPosition: translatedPosition.rank, selectedType: type)
            directionAdded.file = 1
        }
        
        // Tapped on the bottom
        if translatedPosition.rank < bottomRank {
            insertRank(at: bottomRank, selectedPosition: translatedPosition.file, selectedType: type)
            directionAdded.rank = -1
        }
        
        // tapped on the top
        if translatedPosition.rank > topRank {
            insertRank(at: topRank + 1, selectedPosition: translatedPosition.file, selectedType: type)
            directionAdded.rank = 1
        }
        
        updateSquarePositions()
        changedGame(game)
        updateEmptyBoard()
        
        print("game.ranks: \(ranks)")
        print("game.files: \(files)")
        
        return directionAdded
    }
    
    /// Inserts an empty file to the board at the specified file index.
    /// Every square is .nonexistent with type 'selectedType'
    /// Except for the square at 'selectedPosition', which is .empty
    private func insertFile(at file: Int, selectedPosition: Int, selectedType: Square.SquareType) {
        print("selectedType: \(selectedType)")
        print("inserting file at \(file), selectedRank: \(selectedPosition)")
        var newFile = [Square]()
        for rank in 0..<ranks {
            let position = Position(rank: rank, file: file)
            let type = abs(rank - selectedPosition) % 2 == 1 ? selectedType : selectedType.opposite
            newFile.insert(
                Square(
                    state: .nonexistent,
                    position: position,
                    type: type
                ),
                at: rank
            )
        }
        
        game.board.squares.insert(newFile, at: file)
        
        if (0..<ranks).contains(selectedPosition) {
            game.board.squares[file][selectedPosition].state = .empty
        }
    }
    
    /// Inserts an empty rank to the board at the specified file index
    /// Every square is .nonexistent with type 'selectedType'
    /// Except for the square at 'selectedPosition', which is .empty
    private func insertRank(at rank: Int, selectedPosition: Int, selectedType: Square.SquareType) {
        print("selectedType: \(selectedType)")
        print("inserting rank at \(rank), selectedFile: \(selectedPosition)")
        for file in 0..<files {
            let position = Position(rank: rank, file: file)
            let type = abs(file - selectedPosition) % 2 == 1 ? selectedType : selectedType.opposite
            game.board.squares[file].insert(
                Square(
                    state: .nonexistent,
                    position: position,
                    type: type
                ),
                at: rank
            )
        }
        
        if (0..<files).contains(selectedPosition) {
            game.board.squares[selectedPosition][rank].state = .empty
        }
    }
    
    private func updateSquarePositions() {
        for file in 0..<files {
            for rank in 0..<ranks {
                game.board.squares[file][rank].position = Position(rank: rank, file: file)
            }
        }
    }
    
    /// Given a position where a square was removed, checks if the associated ranks are
    /// empty, and removes them if they are.
    /// Returns a Position corresponding to the direction the square was added ((rank, file))
    /// and number of squares added
    /// (-1, -1) would be the bottom left, (1, 1) would be the top right, (-1, 0) would be the bottom
    private func trimSquaresIfNecessary() -> Position {
        var directionRemoved = Position(rank: 0, file: 0)
        return trimSquaresIfNecessary(directionRemoved: &directionRemoved)
    }
    
    /// Given a position where a square was removed, checks if the associated ranks are
    /// empty, and removes them if they are.
    /// Returns a Position corresponding to the direction the square was added ((rank, file))
    /// and number of squares added
    /// (-1, -1) would be the bottom left, (1, 1) would be the top right, (-1, 0) would be the bottom
    private func trimSquaresIfNecessary(directionRemoved: inout Position) -> Position {
        var didTrim = false
        
        let bottomRank = 0
        let topRank = ranks - 1
        let leftmostFile = 0
        let rightmostFile = files - 1

        // Check all sides
        
        // Bottom
        if removeRankIfEmpty(bottomRank) {
            didTrim = true
            directionRemoved.rank += -1
        }

        // Top
        if removeRankIfEmpty(topRank) {
            didTrim = true
            directionRemoved.rank += 1
        }

        // Left
        if removeFileIfEmpty(leftmostFile) {
            didTrim = true
            directionRemoved.file += -1
        }

        // Right
        if removeFileIfEmpty(rightmostFile) {
            didTrim = true
            directionRemoved.file += 1
        }
        
        if didTrim {
            return trimSquaresIfNecessary(directionRemoved: &directionRemoved)
        } else {
            return directionRemoved
        }
    }
//    private func trimSquaresIfNecessary(afterSquareRemovedAt removedPosition: Position, sideLength: CGFloat) -> Position {
//        var directionRemoved = Position(rank: 0, file: 0)
//        //var removedSquare: Bool = false
//
//        let bottomRank = 0
//        let topRank = ranks - 1
//        let leftmostFile = 0
//        let rightmostFile = files - 1
//
//        // Removed from bottom
//        if removedPosition.rank == bottomRank {
//            if removeRankIfEmpty(bottomRank) {
//                //removedSquare = true
//                directionRemoved.rank = -1
//            }
//        }
//
//        // Removed from top
//        if removedPosition.rank == topRank {
//            if removeRankIfEmpty(topRank) {
//                //removedSquare = true
//                directionRemoved.rank = 1
//            }
//        }
//
//        // Removed from left
//        if removedPosition.file == leftmostFile {
//            if removeFileIfEmpty(leftmostFile) {
//                //removedSquare = true
//                directionRemoved.file = -1
//            }
//        }
//
//        // Removed from right
//        if removedPosition.file == rightmostFile {
//            if removeFileIfEmpty(rightmostFile) {
//                //removedSquare = true
//                directionRemoved.file = 1
//            }
//        }
//
//        return directionRemoved
//
//        //updateBottomLeftSquareColor() // Implement later
//    }
    
    /// Removes the rank in game.board if all squares in it are nonexistent.
    /// If the rank is not in the board, does nothing and returns false
    /// Returns true if it removed the rank, and false otherwise
    private func removeRankIfEmpty(_ rank: Int) -> Bool {
        guard rank >= 0 && rank < ranks else { return false }

        for file in game.board.squares {
            if file[rank].state != .nonexistent {
                return false
            }
        }

        // If the rank is empty, remove it
        for (fileIndex, _) in game.board.squares.enumerated() {
            game.board.squares[fileIndex].remove(at: rank)
        }

        return true
    }

    /// Removes the file in game.board if all squares in it are nonexistent
    /// If the file is not in the board, does nothing and returns false
    /// Returns true if it removed the rank, and false otherwise
    private func removeFileIfEmpty(_ file: Int) -> Bool {
        guard file >= 0 && file < files else { return false }
        if !game.board.squares[file].contains(where: { $0.state != .nonexistent }) {
            game.board.squares.remove(at: file)
            return true
        }
        
        return false
    }
    
    func updateEmptyBoard() {
        self.emptyBoard = Board.empty(
            ranks: game.board.ranks + 2,
            files: game.board.files + 2,
            bottomLeftSquareColor: game.board.bottomLeftSquareColor
        )
    }
    
    init(game: Game, changedGame: @escaping (Game) -> Void) {
        self.game = game
        self.changedGame = changedGame
        self.emptyBoard = Board.empty(
            ranks: game.board.ranks + 2,
            files: game.board.files + 2,
            bottomLeftSquareColor: .light
        )
    }
}


//
//import SwiftUI
//
//class EditBoardViewModel: ObservableObject {
//    @Published var bottomLeftSquareColor: Square.SquareType
//
//    /// Selects the position on the board. If the square has a piece, does nothing. Otherwise, toggles
//    /// The existence of the square on/off.
//    func selectedPositionOnBoard(_ selectedPosition: Position, sideLength: CGFloat) {
//        if let square = game.board.squares[selectedPosition],
//           square.state == .empty {
//            game.board.squares[selectedPosition]?.state = .nonexistent
//
//            trimSquaresIfNecessary(afterSquareRemovedAt: selectedPosition, sideLength: sideLength)
//        }
//    }
//
//    var emptySquares: [[Square]] {
//        return Board.empty(
//            ranks: game.board.ranks + 2,
//            files: game.board.files + 2,
//            bottomLeftSquareColor: bottomLeftSquareColor
//        ).squares
//    }
//
//    private(set) var game: Game
//    private var ranks: Int { game.board.squares.first?.count ?? 0 }
//    private var files: Int { game.board.squares.count }
//
//    /// Given a position where a square was removed, checks if the associated ranks are
//    /// empty, and removes them if they are.
//    private func trimSquaresIfNecessary(afterSquareRemovedAt removedPosition: Position, sideLength: CGFloat) {
//        var removedSquare: Bool = false
//
//        let bottomRank = 0
//        let topRank = ranks - 1
//        let leftmostFile = 0
//        let rightmostFile = files - 1
//
//        // Removed from bottom
//        if removedPosition.rank == bottomRank {
//            if removeRankIfEmpty(bottomRank) { removedSquare = true }
//        }
//
//        // Removed from top
//        if removedPosition.rank == topRank {
//            if removeRankIfEmpty(topRank) { removedSquare = true }
//        }
//
//        // Removed from left
//        if removedPosition.file == leftmostFile {
//            if removeFileIfEmpty(leftmostFile) { removedSquare = true }
//        }
//
//        // Removed from right
//        if removedPosition.file == rightmostFile {
//            if removeFileIfEmpty(rightmostFile) { removedSquare = true }
//        }
//
//        updateBottomLeftSquareColor()
//
//        // Call recursively
//    }
//
//    /// Removes the rank in game.board if all squares in it are nonexistent.
//    /// If the rank is not in the board, does nothing and returns false
//    /// Returns true if it removed the rank, and false otherwise
//    private func removeRankIfEmpty(_ rank: Int) -> Bool {
//        guard rank >= 0 && rank < ranks else { return false }
//
//        for file in game.board.squares {
//            if file[rank].state != .nonexistent {
//                return false
//            }
//        }
//
//        // If the rank is empty, remove it
//        for (fileIndex, _) in game.board.squares.enumerated() {
//            game.board.squares[fileIndex].remove(at: rank)
//        }
//
//        return true
//    }
//
//    /// Removes the file in game.board if all squares in it are nonexistent
//    /// If the file is not in the board, does nothing and returns false
//    /// Returns true if it removed the rank, and false otherwise
//    private func removeFileIfEmpty(_ file: Int) -> Bool {
//        guard file >= 0 && file < files else { return false }
//        if !game.board.squares[file].contains(where: { $0.state != .nonexistent }) {
//            game.board.squares.remove(at: file)
//            return true
//        }
//    }
//
//    private func bottomLeftSquareColor(for board: [[Square]]) -> Square.SquareType {
//        var bottomLeftSquareColor: Square.SquareType
//        let coloredSquareFile = board.first(where: { $0.contains { $0.state != .nonexistent } })
//        if let coloredSquare = coloredSquareFile?.first(where: { $0.state != .nonexistent }) {
//            let squaresAway = coloredSquare.position.rank + coloredSquare.position.file
//            if squaresAway % 2 == 0 {
//                bottomLeftSquareColor = coloredSquare.type
//            } else {
//                bottomLeftSquareColor = coloredSquare.type.opposite
//            }
//        } else {
//            bottomLeftSquareColor = .dark
//        }
//
//        return bottomLeftSquareColor
//    }
//
//    private func updateBottomLeftSquareColor() {
//        bottomLeftSquareColor = bottomLeftSquareColor(for: game.board.squares)
//    }
//
//    init(game: Game) {
//        self.game = game
//        updateBottomLeftSquareColor()
//    }
//}
