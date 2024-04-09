//
//  LocalDataSource.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

class LocalDataSource<Entity: NSManagedObject & CoreDataRepresentable> {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func save(models: [Entity.Model]) async throws {
        let context = container.newBackgroundContext()
        do {
            try await context.perform {
                for model in models {
                    guard let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Entity.self), into: context) as? Entity else {
                        continue
                    }
                    entity.update(with: model, in: context)
                }
                do {
                    try context.save()
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
    
    func fetchAll() async throws -> [Entity.Model] {
        let context = container.viewContext
        let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { $0.toModel() }
        } catch {
            throw error
        }
    }
    
    func create(model: Entity.Model) async throws {
        try await save(models: [model])
    }
    
    func update(model: Entity.Model) async throws where Entity.Model: IdentifiableModel {
        let context = container.newBackgroundContext()
        return try await context.perform {
            let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
            request.predicate = NSPredicate(format: "id == %@", model.id)
            
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.update(with: model, in: context)
                try context.save()
            } else {
                throw NSError(domain: "UpdateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Entity to update not found."])
            }
        }
    }
    
    func fetchById(id: String) async throws -> Entity.Model? {
        let context = container.viewContext
        let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let results = try context.fetch(request)
        return results.first?.toModel()
    }
    
    func deleteById(id: String) async throws {
        let context = container.newBackgroundContext()
        do {
            try await context.perform {
                let request = Entity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                
                do {
                    try context.execute(deleteRequest)
                    try context.save()
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
}

extension LocalDataSource where Entity == UserEntity {
    
    // Save or update the current user in local storage
    func saveOrUpdateUser(model: UserModel) async throws {
        let context = container.newBackgroundContext()
        do {
            try await context.perform {
                // Check if the user already exists
                let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", model.id)
                
                do {
                    let results = try context.fetch(request)
                    let userEntity: UserEntity
                    if results.isEmpty {
                        userEntity = UserEntity(context: context)
                    } else {
                        userEntity = results.first!
                    }
                    
                    // Update the UserEntity with the UserModel data
                    userEntity.update(with: model, in: context)
                    try context.save()
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
    
    // Fetch the current user from local storage
    func fetchCurrentUser() async throws -> UserModel? {
        let context = container.viewContext
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.first?.toModel()
        } catch {
            throw error
        }
    }
    
    // Remove the current user from local storage upon sign-out
    func removeCurrentUser() async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
            // Again, assuming you have a unique way to identify the current user
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                throw error
            }
        }
    }
}
