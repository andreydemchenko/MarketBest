//
//  CategoryRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

protocol CategoryRepository {
    func fetchCategories(categoryIds: [UUID]?) async throws -> [CategoryModel]
    func createCategory(category: CategoryModel) async throws
    func editCategory(category: CategoryModel) async throws
}
