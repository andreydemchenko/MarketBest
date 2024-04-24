//
//  CreateCategoryUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

class CreateCategoryUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute(category: CategoryModel) async throws {
        return try await repository.createCategory(category: category)
    }
}
