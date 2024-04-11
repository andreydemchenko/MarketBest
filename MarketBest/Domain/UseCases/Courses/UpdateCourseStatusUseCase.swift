//
//  UpdateCourseStatusUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation

class UpdateCourseStatusUseCase {
    private let repository: CourseRepository
    
    init(repository: CourseRepository) {
        self.repository = repository
    }
    
    func execute(courseId: UUID, status: CourseStatus) async throws {
        return try await repository.updateCourseStatus(id: courseId, status: status)
    }
}
