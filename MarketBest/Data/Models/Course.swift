//
//  Course.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

struct CourseModel: SupabaseModel, IdentifiableModel {
    
    static let tableName = "courses"
    
    let id: UUID
    let userId: UUID
    let name: String
    let description: String
    let price: Double
    let materialsText: String
    let materialsUrl: String
    let status: CourseStatus
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", name, price, description, status, materialsText = "materials_text", materialsUrl = "materials_url", createdAt = "created_at"
    }
}

extension CourseEntity: CoreDataRepresentable {
    
    typealias Model = CourseModel

    func update(with model: CourseModel, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.courseDescription = model.description
        self.price = model.price
        self.status = model.status.rawValue
        self.materialsUrl = model.materialsUrl
        self.materialsText = model.materialsText
        self.createdAt = model.createdAt
        if let userEntity = try? context.fetch(UserEntity.fetchRequest()).first(where: { $0.id == model.userId }) {
            self.user = userEntity
        }
    }
    
    func toModel() -> CourseModel {
        return CourseModel(
            id: id ?? UUID(),
            userId: user!.id!,
            name: name!,
            description: description,
            price: price,
            materialsText: materialsText!,
            materialsUrl: materialsUrl!,
            status: CourseStatus.withLabel(status ?? "") ?? .uncompleted,
            createdAt: createdAt!
        )
    }
    
    func hasChanges(comparedTo model: CourseModel) -> Bool {
        return self.id != model.id ||
        self.name != model.name ||
        self.courseDescription != model.description ||
        self.price != model.price ||
        self.status != model.status.rawValue ||
        self.materialsUrl != model.materialsUrl ||
        self.materialsText != model.materialsText ||
        self.createdAt != model.createdAt ||
        self.user?.id != model.userId
    }
}

enum CourseStatus: String, Codable, CaseIterable {
    case uncompleted
    case moderation
    case rejected
    case archived
    case active
    
    static func withLabel(_ label: String) -> CourseStatus? {
        return self.allCases.first{ "\($0)" == label }
    }
}
