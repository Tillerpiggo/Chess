//
//  BoardSetupPosition.swift
//  Chess
//
//  Created by Tyler Gee on 1/5/23.
//  Copyright © 2023 Beaglepig. All rights reserved.
//

import Foundation

/// Describes how to set up pieces on some (unknown) Board
struct SetupPosition {
    
    // Inv: no two elements in pieces have the same position
    private var pieces: [SetupPiece]
    
    /// Moves a piece in the setup. If the move is illegal (ie there is no piece to be moved or the move goes out of bounds), then
    /// this does nothing.
    mutating func applyMove(_ move: Move, inBoard board: Board) {
        guard let movedPieceIndex = pieces.firstIndex(where: { $0.position == move.start }), board.containsSquare(atPosition: move.end) else { return }
        
        if let overwrittenPieceIndex = pieces.firstIndex(where: { $0.position == move.end }) {
            pieces.remove(at: overwrittenPieceIndex)
        }
        
        pieces[movedPieceIndex].position = move.end
    }
    
    /// Adds the piece to this setup. If there is already a piece at the given position, overwrites it.
    mutating func addPieceWithID(_ id: UUID, atPosition position: Position, player: Player) {
        let addedPiece = SetupPiece(id: id, position: position, player: player)
        if let pieceIndex = pieces.firstIndex(where: { $0.position == addedPiece.position }) {
            pieces[pieceIndex] = addedPiece
        } else {
            pieces.append(addedPiece)
        }
    }
    
    /// Adds the piece to this setup. If there is already a piece at the given position, overwrites it. "ID" must correspond to a valid UUIDString, or this crashes.
    mutating func addPieceWithID(_ id: String, atPosition position: Position, player: Player) {
        addPieceWithID(UUID(uuidString: id)!, atPosition: position, player: player)
    }
    
    /// Removes the piece at the position from this setup. If no piece is at the position, does nothing.
    mutating func removePiece(atPosition position: Position) {
        pieces.removeAll(where: { $0.position == position })
    }
    
    func forEachPiece(perform: (UUID, Position, Player) -> Void) {
        for piece in pieces {
            perform(piece.id, piece.position, piece.player)
        }
    }
    
    private struct SetupPiece {
        var id: UUID // the id for the *type* of piece (as defined by the Game)
        var position: Position
        var player: Player
       
        init(id: UUID, position: Position, player: Player) {
            self.id = id
            self.position = position
            self.player = player
        }
       
        init?(setupPieceModel: SetupPieceModel) {
            guard
                let positionModel = setupPieceModel.position, let position = Position(positionModel: positionModel),
                let id = setupPieceModel.id,
                let playerModel = setupPieceModel.player, let player = Player(rawValue: Int(playerModel.player))
            else {
                print("Failed to initialize piece out of setupPieceModel")
                return nil
            }
            
            self.position = position
            self.id = id
            self.player = player
        }
    }
    
    init() {
        self.pieces = []
    }
    
    /// Initializes this so that each string in strings represents a rank. Each character either represents a piece or
    /// an empty square (if it is a space). PieceSymbols tells this how to interpret each character.
    init(fromStrings strings: [String], pieceSymbols: [Character: (UUID, Player)]) {
        self.pieces = []
        
        for (index, string) in strings.enumerated() {
            let rank = strings.count - index - 1 // so that strings[0] is the last rank
            
            for (file, character) in string.enumerated() {
                if let (id, player) = pieceSymbols[character] {
                    addPieceWithID(id, atPosition: Position(rank: rank, file: file), player: player)
                }
            }
        }
    }
    
    init?(setupPositionModel: SetupPositionModel) {
        guard let pieces = setupPositionModel.pieces?.allObjects as? [SetupPieceModel] else {
            print("Failed to initialize setupPositionModel out of setupPieces")
            return nil
        }
        
        self.pieces = pieces.compactMap { SetupPiece(setupPieceModel: $0) }
    }
    
}
