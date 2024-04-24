//
//  CreateMediaItemUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class CreateMediaItemUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(mediaItem: CourseMediaItem) async throws {
        return try await repository.createCourseMediaItem(media: mediaItem)
    }
}
