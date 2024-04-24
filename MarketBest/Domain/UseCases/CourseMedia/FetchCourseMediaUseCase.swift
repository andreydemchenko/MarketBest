//
//  FetchMediaUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class FetchCourseMediaUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(courseId: UUID) async throws -> [CourseMediaItem] {
        return try await repository.fetchCourseMedia(courseId: courseId)
    }
    
}
