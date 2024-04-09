//
//  FetchCoursesUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

class FetchCoursesUseCase {
    private let repository: CourseRepository
    
    init(repository: CourseRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [CourseModel] {
        return try await repository.fetchCourses()
    }
}
