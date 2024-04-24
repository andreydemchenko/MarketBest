//
//  EditCategoryUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

class EditCategoryUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute(category: CategoryModel) async throws {
        return try await repository.editCategory(category: category)
    }
}
