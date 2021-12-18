////
////  EditBoardViewModel.swift
////  Chess
////
////  Created by Tyler on 10/31/21.
////  Copyright © 2021 Beaglepig. All rights reserved.
////


import SwiftUI

class EditBoardViewModel: ObservableObject {
    var changedGame: (Game) -> Void
    
    init(changedGame: @escaping (Game) -> Void) {
        self.changedGame = changedGame
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
