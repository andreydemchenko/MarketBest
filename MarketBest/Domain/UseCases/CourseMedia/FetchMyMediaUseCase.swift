//
//  FetchMyMediaUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class FetchMyMediaUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(userId: UUID) async throws -> [CourseMediaItem] {
        return try await repository.fetchMyMedia(userId: userId)
    }
}
