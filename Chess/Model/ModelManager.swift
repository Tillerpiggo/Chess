//
//  PieceCoreDataManager.swift
//  Chess
//
//  Created by Tyler Gee on 8/31/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreData
import Combine

class ModelManager<Model: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
	private(set) var models = CurrentValueSubject<[Model], Never>([])
	
	private let modelFetchController: NSFetchedResultsController<Model>
	private let persistenceController: PersistenceController
	private let context: NSManagedObjectContext
	
	func save() {
		persistenceController.save()
	}
	
	func delete(_ object: NSManagedObject) {
		context.delete(object)
	}
	
	func pieceManager(for game: GameModel) -> ModelManager<PieceModel> {
		let pieceManager = ModelManager<PieceModel>(
			persistenceController: persistenceController,
			sortDescriptors: [NSSortDescriptor(keyPath: \PieceModel.position!.rank, ascending: true)],
			predicate: NSPredicate(format: "%K = %@", (\PieceModel.game!.id)._kvcKeyPathString!, game.id! as CVarArg)
		)
		
		return pieceManager
	}
    
    // For managing the list of pieces that a given piece can promote into
    func promotionPieceManager(for piece: PieceModel) -> ModelManager<PieceModel> {
        //print("# of pieces originally: \(piece.promotionPieces.count)")
        let pieceManager = ModelManager<PieceModel>(
            persistenceController: persistenceController,
            sortDescriptors: [NSSortDescriptor(keyPath: \PieceModel.position!.rank, ascending: true)],
            predicate: NSPredicate(format: "%K IN %@", (\PieceModel.id)._kvcKeyPathString!, piece.promotionPieces ?? [])
        )
        
        return pieceManager
    }
	
	func moverManager(for piece: PieceModel, firstMove: Bool) -> ModelManager<MoverModel> {
		let predicate: NSPredicate =
			NSPredicate(
				format: "%K = %@",
				(firstMove ? \MoverModel.pieceFirstMove!.id : \MoverModel.piece!.id)._kvcKeyPathString!,
				piece.id! as CVarArg
			)
		
		let moverManager = ModelManager<MoverModel>(
			persistenceController: persistenceController,
			sortDescriptors: [],
			predicate: predicate)
		
		return moverManager
	}
	
	/*
	func patternManager(for piece: Piece, movementType: Piece.MovementType) -> ModelManager<PatternModel> {
		let mover: mover
		switch movementType {
		case .normal: mover = piece.mover
		}
		
		let patternManager = ModelManager<PatternModel(
			persistenceController: persistenceController,
			sortDescriptors: [],
			predicate: NSPredicate(format: "%K = %@",
								   (\.PatternModel.mover!.id)._kvcKeyPathString!, mover.id as CVarArg))
	}
*/
	
	// MARK: - Init
	
	init(persistenceController: PersistenceController, sortDescriptors: [NSSortDescriptor], predicate: NSPredicate = NSPredicate(value: true)) {
		self.persistenceController = persistenceController
		self.context = persistenceController.container.viewContext
		
		let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest() as! NSFetchRequest<Model>
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = predicate
		
		modelFetchController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil, cacheName: nil
		)
		
		super.init()
		
		modelFetchController.delegate = self
		
		do {
			try modelFetchController.performFetch()
			models.value = modelFetchController.fetchedObjects ?? []
		} catch {
			NSLog("Error: could not fetch objects")
		}
	}
	
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		guard let models = controller.fetchedObjects as? [Model] else { return }
		
		print("ModelManager detected change in model content, model type: \(Model.self)")
		self.models.value = models
	}
}

extension ModelManager where Model == GameModel {
	var converter: ModelConverter {
		ModelConverter(context: context, games: models.value)
	}
}

