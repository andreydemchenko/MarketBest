//
//  FetchMediaUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class FetchMediaUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(courseId: UUID) async throws -> [CourseMediaItem] {
        return try await repository.fetchMedia(courseId: courseId)
    }
    
}
