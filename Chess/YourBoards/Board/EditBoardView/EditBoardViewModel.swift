////
////  EditBoardViewModel.swift
////  Chess
////
////  Created by Tyler on 10/31/21.
////  Copyright © 2021 Beaglepig. All rights reserved.
////


import SwiftUI

// Manages an interface to modifying a board by adding or removing squares,
// By moving pieces, and by managing the empty "ghost" board
class EditBoardViewModel: ObservableObject {
    var bottomLeftSquareColor: Square.SquareType {
        //print("bottomLeftSquareColor: \(game.board.squares[Position(rank: 0, file: 0)]?.type)")
        return game.board.bottomLeftSquareColor
    }
    
    // a game of type Game, rather than GameModel - TODO: Refactor this when you switch GameModel with Game (so that GameModels are the less used, struct versions that have better features/calculations
    @Published var game: Game
    private var gameChanged: (Game) -> Void
    var board: Board { game.board }
    
    var ranks: Int { game.ranks }
    var files: Int { game.files }
    
    @Published var selectedPlayer: Player = .white
    
    @Published var selectedPiece: UUID?
    
    var emptyBoard: Board {
        return Board.empty(
            ranks: ranks + 2,
            files: files + 2,
            bottomLeftSquareColor: bottomLeftSquareColor
        )
    }
    
    var pieces: [Piece] {
        let selectedPieces: [Piece] = game.pieces.filter { $0.owner == selectedPlayer || $0.owner == .blackOrWhite }
        
        return selectedPieces.map { piece in
            var newPiece = piece
            newPiece.owner = selectedPlayer
            return newPiece
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
        if let move = Move(start: startingPosition, end: endingPosition), game.board.squares[startingPosition]?.state == .occupied, game.board.squares[endingPosition]?.state != .nonexistent {
            
            game.board.moveSetup(move: move)
            gameChanged(game)
        }
    }
    
    func onDrop(_ pieceID: String, at position: Position) {
        guard var droppedPiece = game.pieces.first(where: { $0.id.uuidString == pieceID }) else { return }
        
        droppedPiece.owner = selectedPlayer
        game.board.squares[position]?.setStartingPiece(droppedPiece)
        
        gameChanged(game)
    }
    
    /// Selects the position on the board. If the square has a piece, does nothing. Otherwise, toggles
    /// The existence of the square on/off.
    /// Returns a Position corresponding to the direction the square was removed (0, 0) if it wasn't
    /// (rank, file): (1, 1) would be the top right
    func selectedPositionOnBoard(_ selectedPosition: Position) -> Position {
        var directionRemoved = Position(rank: 0, file: 0)
        
        if let square = board.squares[selectedPosition] {
            if let selectedPiece = selectedPiece {
                
                if square.piece?.id == selectedPiece && square.piece?.owner == selectedPlayer {
                    game.board.squares[selectedPosition]?.setStartingPiece(nil)
                } else {
                    var piece = game.piece(selectedPiece.uuidString)!
                    piece.owner = selectedPlayer
                    game.board.squares[selectedPosition]?.setStartingPiece(piece)
                }
            } else {
                if square.state == .empty {
                    game.board.squares[selectedPosition]?.state = .nonexistent
                } else if square.state == .nonexistent {
                    game.board.squares[selectedPosition]?.state = .empty
                }

                directionRemoved = trimSquaresIfNecessary()
                updateSquarePositions()
            }
            
            gameChanged(game)
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
    
    /// Selects the position on the ghost board. This should add a square
    /// at the position tapped.
    /// Returns a Position corresponding to the direction the square was added ((rank, file))
    /// (-1, -1) would be the bottom left, (1, 1) would be the top right, (-1, 0) would be the bottom
    func selectedPositionOnGhostBoard(_ selectedPosition: Position) -> Position {
        // Translate the position to the position on the actual board
        var translatedPosition = Position(
            rank: selectedPosition.rank - 1,
            file: selectedPosition.file - 1)
        let type = emptyBoard.squares[selectedPosition]!.type
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
        //gameManager.updateGame(game)
        gameChanged(game)
        //updateEmptyBoard()
        
        print("game.ranks: \(ranks)")
        print("game.files: \(files)")
        
        return directionAdded
    }
    
    /// Inserts an empty file to the board at the specified file index.
    /// Every square is .nonexistent with type 'selectedType'
    /// Except for the square at 'selectedPosition', which is .empty
    private func insertFile(at file: Int, selectedPosition: Int, selectedType: Square.SquareType) {
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
        
        gameChanged(game)
    }
    
    /// Inserts an empty rank to the board at the specified file index
    /// Every square is .nonexistent with type 'selectedType'
    /// Except for the square at 'selectedPosition', which is .empty
    private func insertRank(at rank: Int, selectedPosition: Int, selectedType: Square.SquareType) {
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
        
        gameChanged(game)
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
        removeRank(rank)

        return true
    }

    /// Removes the file in game.board if all squares in it are nonexistent
    /// If the file is not in the board, does nothing and returns false
    /// Returns true if it removed the rank, and false otherwise
    private func removeFileIfEmpty(_ file: Int) -> Bool {
        guard file >= 0 && file < files else { return false }
        if !(game.board.squares[file].contains(where: { $0.state != .nonexistent })) {
            removeFile(file)
            return true
        }
        
        return false
    }
    
    // Removes the file from the GameModel
    private func removeFile(_ file: Int) {
        //guard var boardCopy = gameStruct?.board else { return }
        
        game.board.squares.remove(at: file)
        
        gameChanged(game)
    }
    
    // Removes the rank from the GameModel
    private func removeRank(_ rank: Int) {
        //guard var boardCopy = gameStruct?.board else { return }
        
        for (file, _) in game.board.squares.enumerated() {
            game.board.squares[file].remove(at: rank)
        }

        gameChanged(game)
    }
    
    private func updateSquarePositions() {
        for file in 0..<files {
            for rank in 0..<ranks {
                game.board.squares[file][rank].position = Position(rank: rank, file: file)
            }
        }
    }
    
    init(game: GameModel, gameChanged: @escaping (Game) -> Void) {
        self.game = Game(gameModel: game)!
        self.gameChanged = gameChanged
    }
}
