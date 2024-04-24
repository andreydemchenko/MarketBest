//
//  DeleteCourseUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 16.04.2024.
//

import Foundation

class DeleteCourseUseCase {
    
    private let repository: CourseRepository
    
    init(repository: CourseRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID) async throws {
        return try await repository.deleteCourse(id: id)
    }
}
