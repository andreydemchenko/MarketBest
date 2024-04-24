//
//  Category.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation
import CoreData

struct CategoryModel: SupabaseModel, IdentifiableModel {
    
    static let tableName = "categories"
    
    let id: UUID
    let parentCategoryId: UUID?
    let name: String
    let iconUrl: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, parentCategoryId = "parent_category_id", name, iconUrl = "icon", createdAt = "created_at"
    }
}

extension CategoryEntity: CoreDataRepresentable {
    
    typealias Model = CategoryModel
    
    func update(with model: CategoryModel, in context: NSManagedObjectContext) {
        self.id = model.id
        self.createdAt = model.createdAt
        self.name = model.name
        self.iconUrl = model.iconUrl
        if let categoryEntity = try? context.fetch(CategoryEntity.fetchRequest()).first(where: { $0.id == model.parentCategoryId }) {
            self.parentCategory = categoryEntity
        }
    }
    
    func toModel() -> CategoryModel {
        return CategoryModel(
            id: id ?? UUID(),
            parentCategoryId: parentCategory?.id,
            name: name ?? "",
            iconUrl: iconUrl,
            createdAt: createdAt ?? Date()
        )
    }
    
    func hasChanges(comparedTo model: CategoryModel) -> Bool {
        return self.id != model.id ||
        self.createdAt != model.createdAt ||
        self.name != model.name ||
        self.parentCategory?.id != model.parentCategoryId ||
        self.iconUrl != model.iconUrl
    }
}
