//
//  User.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

struct UserModel: SupabaseModel, IdentifiableModel {
    static let tableName = "users"
    
    let id: UUID
    let name: String
    let email: String
    var role: UserRole = .customer
    var createdAt: Date = Date()
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, createdAt = "created_at", imageUrl = "image_url"
    }
}

enum UserRole: String, Codable, CaseIterable {
    case guest = "guest"
    case customer = "customer"
    case admin = "admin"
    
    static func withLabel(_ label: String) -> UserRole? {
        return self.allCases.first{ "\($0)" == label }
    }
}


extension UserEntity: CoreDataRepresentable {
    
    typealias Model = UserModel

    func update(with model: UserModel, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.email = model.email
        self.role = model.role.rawValue
        self.createdAt = model.createdAt
        self.imageUrl = model.imageUrl
        
        // Set related courses
        let courseFetchRequest: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
        courseFetchRequest.predicate = NSPredicate(format: "user.id == %@", model.id as CVarArg)
        if let relatedCourses = try? context.fetch(courseFetchRequest) {
            self.addToCourses(NSSet(array: relatedCourses))
        }
        
        // Set related orders
        let orderFetchRequest: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        orderFetchRequest.predicate = NSPredicate(format: "user.id == %@", model.id as CVarArg)
        if let relatedOrders = try? context.fetch(orderFetchRequest) {
            self.addToOrders(NSSet(array: relatedOrders))
        }
    }
    
    func toModel() -> UserModel {
        return UserModel(
            id: id ?? UUID(),
            name: name ?? "",
            email: email ?? "",
            role: UserRole.withLabel(role ?? "") ?? .customer,
            createdAt: createdAt ?? Date(),
            imageUrl: imageUrl
        )
    }
}

extension UserEntity {
    /// Checks if the UserEntity has different data from the UserModel.
    func hasChanges(comparedTo model: UserModel) -> Bool {
        return self.name != model.name ||
               self.email != model.email ||
               self.role != model.role.rawValue ||
               self.createdAt != model.createdAt ||
               self.imageUrl != model.imageUrl
    }
}


