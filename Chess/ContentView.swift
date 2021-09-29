//
//  ContentView.swift
//  Chess
//
//  Created by Tyler Gee on 7/22/20.
//  Copyright © 2020 Beaglepig. All rights reserved.
//

/*
import SwiftUI

struct ContentView: View {
	
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@FetchRequest(
		entity: BoardData.entity(),
		sortDescriptors: [
			NSSortDescriptor(keyPath: \BoardData.name, ascending: true)
		]
	) var boards: FetchedResults<BoardData>
	
    var body: some View {
		List(boards, id: \.self) { board in
			HStack {
				Text(board.name ?? "unknown")
				Text(board.creator ?? "unknown")
			}
		}
		//BoardView(squares: board.squares)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
