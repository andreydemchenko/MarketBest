//
//  CoreDataRepresentable.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

protocol CoreDataRepresentable {
    associatedtype Model
    func update(with model: Model, in context: NSManagedObjectContext)
    func toModel() -> Model 
}

protocol IdentifiableModel {
    var id: String { get }
}
