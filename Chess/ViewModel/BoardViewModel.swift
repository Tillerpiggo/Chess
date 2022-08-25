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
    
    @Published var boardModel: BoardModel
    var board: Board { Board(boardModel: boardModel)! }
    var ranks: Int { board.ranks }
    var files: Int { board.files }
    
    init(board: BoardModel) {
        self.boardModel = board
    }
}
