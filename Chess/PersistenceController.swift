//
//  PersistenceController.swift
//  Chess
//
//  Created by Tyler Gee on 8/2/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData

struct PersistenceController {
	// A singleton for our entire app to use
	static let shared = PersistenceController()
	
	// Storage for Core Data
	let container: NSPersistentContainer
	
	// A test configuration for SwiftUI previews
	static var preview: PersistenceController = {
		let controller = PersistenceController(inMemory: true)
		
		// Create 10 examples boards
		for _ in 0..<10 {
			let game = GameModel(context: controller.container.viewContext)
			game.name = "Test name"
		}
		
		return controller
	}()
	
	// An initializer to load Core Data, optionally able
	// to use an in-memory store.
	init(inMemory: Bool = false) {
		// This name must match the name of the .xcdatamodelId
		container = NSPersistentContainer(name: "Main")
		
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}
		
		container.loadPersistentStores { description, error in
			if let error = error {
				fatalError("Error: \(error.localizedDescription)")
			}
		}
	}
	
	func save() {
		let context = container.viewContext
		
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// TODO: Add error handling here
			}
		}
	}
}
