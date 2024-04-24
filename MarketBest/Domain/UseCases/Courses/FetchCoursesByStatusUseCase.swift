//
//  FetchCoursesByStatusUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

class FetchCoursesByStatusUseCase {
    
    private let repository: CourseRepository
    
    init(repository: CourseRepository) {
        self.repository = repository
    }
    
    func execute(status: CourseStatus) async throws -> [CourseModel] {
        return try await repository.fetchCoursesByStatus(status: status)
    }
}
