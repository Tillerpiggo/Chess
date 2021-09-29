//
//  GameModel+CoreDataProperties.swift
//  Chess
//
//  Created by Tyler Gee on 8/4/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData


extension GameModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameModel> {
        return NSFetchRequest<GameModel>(entityName: "GameModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var board: BoardModel?
    @NSManaged public var squares: NSSet?

}

// MARK: Generated accessors for squares
extension GameModel {

    @objc(addSquaresObject:)
    @NSManaged public func addToSquares(_ value: SquareModel)

    @objc(removeSquaresObject:)
    @NSManaged public func removeFromSquares(_ value: SquareModel)

    @objc(addSquares:)
    @NSManaged public func addToSquares(_ values: NSSet)

    @objc(removeSquares:)
    @NSManaged public func removeFromSquares(_ values: NSSet)

}

extension GameModel : Identifiable {

}
