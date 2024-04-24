//
//  FetchAllMediaUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class FetchAllMediaUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [CourseMediaItem] {
        return try await repository.fetchAllMedia()
    }
    
}
