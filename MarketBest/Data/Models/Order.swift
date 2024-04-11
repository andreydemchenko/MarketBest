//
//  Order.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation
import CoreData

struct OrderModel: SupabaseModel, IdentifiableModel {
    static let tableName = "orders"
    
    let id: UUID
    let userId: UUID  // cpecified in supabase like foreign key to users table
    let courseId: UUID  // cpecified in supabase like foreign key to courses table
    let createdAt: Date
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", courseId = "course_id", createdAt = "created_at", price
    }
}

extension OrderEntity: CoreDataRepresentable {
    
    typealias Model = OrderModel
    
    func update(with model: OrderModel, in context: NSManagedObjectContext) {
        self.id = model.id
        self.createdAt = model.createdAt
        self.price = model.price
        if let userEntity = try? context.fetch(UserEntity.fetchRequest()).first(where: { $0.id == model.userId }) {
            self.user = userEntity
        }
        
        if let courseEntity = try? context.fetch(CourseEntity.fetchRequest()).first(where: { $0.id == model.courseId }) {
            self.course = courseEntity
        }
    }
    
    func toModel() -> OrderModel {
        return OrderModel(
            id: id ?? UUID(),
            userId: user?.id ?? UUID(),
            courseId: course?.id ?? UUID(),
            createdAt: createdAt ?? Date(),
            price: price
        )
    }
    
    func hasChanges(comparedTo model: OrderModel) -> Bool {
        return self.id != model.id ||
        self.createdAt != model.createdAt ||
        self.price != model.price ||
        self.user?.id != model.userId ||
        self.course?.id != model.courseId
    }
}
