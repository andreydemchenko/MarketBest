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
    
    func saveOrUpdate(models: [Entity.Model]) async throws where Entity.Model: IdentifiableModel  {
        let context = container.newBackgroundContext()
        
        do {
            try await context.perform {
                for model in models {
                    let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
                    request.predicate = NSPredicate(format: "id == %@", model.id.uuidString)
                    
                    do {
                        let results = try context.fetch(request)
                        
                        if let existingEntity = results.first {
                            // Check if the existing entity needs updating
                            if existingEntity.hasChanges(comparedTo: model) {
                                existingEntity.update(with: model, in: context)
                            } else {
                                // No update needed, continue to the next model
                                continue
                            }
                        } else {
                            // Entity does not exist, insert a new one
                            guard let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Entity.self), into: context) as? Entity else {
                                continue
                            }
                            newEntity.update(with: model, in: context)
                        }
                    } catch {
                        // Handle fetch error
                        throw error
                    }
                }
            }
        } catch {
            // Handle fetch error
            throw error
        }
        
        // Save changes if there are any
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
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
    
    func create(model: Entity.Model) async throws where Entity.Model: IdentifiableModel {
        try await saveOrUpdate(models: [model])
    }
    
    func update(model: Entity.Model) async throws where Entity.Model: IdentifiableModel {
        let context = container.newBackgroundContext()
        return try await context.perform {
            let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
            request.predicate = NSPredicate(format: "id == %@", model.id.uuidString)
            
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
                request.predicate = NSPredicate(format: "id == %@", model.id.uuidString)
                
                let results = try context.fetch(request)
                let userEntity: UserEntity
                
                if results.isEmpty {
                    // If user doesn't exist, create new UserEntity
                    userEntity = UserEntity(context: context)
                    userEntity.update(with: model, in: context)
                } else if let existingUser = results.first {
                    // Check if any data has changed before updating
                    if existingUser.hasChanges(comparedTo: model) {
                        existingUser.update(with: model, in: context)
                    }
                    // No need to save if there are no changes
                }
                
                // Save only if there are changes in the context to be persisted
                if context.hasChanges {
                    try context.save()
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

extension LocalDataSource where Entity == CourseEntity {
    
    func updateCourseStatus(id: UUID, status: CourseStatus) async throws {
        let context = container.newBackgroundContext()
        do {
            try await context.perform {
                let request: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id.uuidString)
                
                do {
                    let results = try context.fetch(request)
                    if let course = results.first {
                        course.status = status.rawValue
                        try context.save()
                    } else {
                        // Handle the case where the course wasn't found
                        throw NSError(domain: "ru.turbopro.marketbest", code: 404, userInfo: [NSLocalizedDescriptionKey: "Course not found"])
                    }
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
    
    func fetchMyCourses(userId: UUID) async throws -> [CourseModel] {
        let context = container.viewContext
        return try await context.perform {
            let request: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
            
            do {
                let results = try context.fetch(request)
                return results.map { $0.toModel() }
            } catch {
                throw error
            }
        }
    }
}
