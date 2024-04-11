//
//  FetchMyCoursesUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation

class FetchMyCoursesUseCase {
    private let repository: CourseRepository
    
    init(repository: CourseRepository) {
        self.repository = repository
    }
    
    func execute(userId: UUID) async throws -> [CourseModel] {
        return try await repository.fetchMyCourses(userId: userId)
    }
}
