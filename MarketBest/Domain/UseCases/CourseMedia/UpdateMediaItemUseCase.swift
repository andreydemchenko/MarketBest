//
//  UpdateMediaItemUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 16.04.2024.
//

import Foundation

class UpdateMediaItemUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(mediaItem: CourseMediaItem) async throws {
        return try await repository.updateMediaItem(media: mediaItem)
    }
    
}
