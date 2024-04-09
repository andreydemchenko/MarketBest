//
//  CoreDataStack.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Entities")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error, possibly by logging or presenting an error to the user
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
