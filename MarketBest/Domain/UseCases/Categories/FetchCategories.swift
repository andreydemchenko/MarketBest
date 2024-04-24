//
//  FetchCategories.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

class FetchCategoriesUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute(categoryIds: [UUID]? = nil) async throws -> [CategoryModel] {
        return try await repository.fetchCategories(categoryIds: categoryIds)
    }
}
