//
//  Course.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData
import SwiftUI

struct CourseModel: SupabaseModel, IdentifiableModel {
    
    static let tableName = "courses"
    
    let id: UUID
    let categoryId: UUID
    let userId: UUID
    let name: String
    let description: String?
    let price: Double
    let materialsText: String?
    let materialsUrl: String
    let status: CourseStatus
    let createdAt: Date
    let updatedAt: Date
    
    var media: [CourseMediaItem] = []
    var parentCategoryName: String = ""
    var parentCategoryIconUrl: String? = nil
    var categoryName: String = ""
    var categoryIconUrl: String? = nil
    var isMyFavourite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, categoryId = "category_id", userId = "user_id", name, price, description, status, materialsText = "materials_text", materialsUrl = "materials_url", createdAt = "created_at", updatedAt = "updated_at"
    }
    
    static func ==(lhs: CourseModel, rhs: CourseModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.price == rhs.price &&
        lhs.materialsUrl == rhs.materialsUrl &&
        lhs.materialsText == rhs.materialsText &&
        lhs.status == rhs.status &&
        lhs.categoryName == rhs.categoryName &&
        lhs.categoryIconUrl == rhs.categoryIconUrl &&
        lhs.parentCategoryName == rhs.parentCategoryName &&
        lhs.parentCategoryIconUrl == rhs.parentCategoryIconUrl &&
        lhs.isMyFavourite == rhs.isMyFavourite
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
            categoryId: categoryId!,
            userId: user!.id!,
            name: name!,
            description: description,
            price: price,
            materialsText: materialsText!,
            materialsUrl: materialsUrl!,
            status: CourseStatus.withLabel(status ?? "") ?? .uncompleted,
            createdAt: createdAt!,
            updatedAt: Date() // fix it
        )
    }
    
    func hasChanges(comparedTo model: CourseModel) -> Bool {
        return self.id != model.id ||
        self.categoryId != model.categoryId ||
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
