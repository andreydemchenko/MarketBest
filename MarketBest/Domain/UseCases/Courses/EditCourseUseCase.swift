//
//  EditCourseUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation

class EditCourseUseCase {
    private let repository: CourseRepository
    
    init(repository: CourseRepository) {
        self.repository = repository
    }
    
    func execute(course: CourseModel) async throws {
        return try await repository.editCourse(course: course)
    }
}
