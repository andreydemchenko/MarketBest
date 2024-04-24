//
//  CategoryRepositoryImpl.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

class CategoryRepositoryImpl: CategoryRepository {
    
    private let remoteDataSource: RemoteDataSource<CategoryModel>
    private let localDataSource: LocalDataSource<CategoryEntity>
    
    init(remoteDataSource: RemoteDataSource<CategoryModel>, localDataSource: LocalDataSource<CategoryEntity>) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchCategories(categoryIds: [UUID]?) async throws -> [CategoryModel] {
        do {
            // Attempt to fetch courses from the remote data source
            var categories: [CategoryModel] = []
            if let categoryIds {
                categories = try await remoteDataSource.fetchByIds(ids: categoryIds)
            } else {
                categories = try await remoteDataSource.fetchAll()
            }
            //try await localDataSource.saveOrUpdate(models: courses)
            return categories
        } catch {
            // On failure, attempt to fetch courses from the local data source
            //            let localCourses = try await localDataSource.fetchAll()
            //            return localCourses
            throw error
        }
    }
    
    func createCategory(category: CategoryModel) async throws {
        do {
            try await remoteDataSource.create(model: category)
            try await localDataSource.create(model: category)
        } catch {
            throw error
        }
    }
    
    func editCategory(category: CategoryModel) async throws {
        do {
            try await remoteDataSource.update(model: category)
            try await localDataSource.update(model: category)
        } catch {
            throw error
        }
    }
    
}
