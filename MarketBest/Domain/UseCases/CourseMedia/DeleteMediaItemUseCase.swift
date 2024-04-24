//
//  DeleteMediaItemUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class DeleteMediaItemUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(mediaItem: CourseMediaItem) async throws {
        if let name = mediaItem.name {
            try await repository.removeMediaItem(fileName: name)
        }
        try await repository.deleteMediaItem(id: mediaItem.id)
    }
    
}
