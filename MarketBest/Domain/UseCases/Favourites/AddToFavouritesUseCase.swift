//
//  AddToFavouritesUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

class AddToFavouritesUseCase {
    
    private let repository: FavouritesRepository
    
    init(repository: FavouritesRepository) {
        self.repository = repository
    }
    
    func execute(userId: UUID, courseId: UUID) async throws {
        return try await repository.addToFavourites(userId: userId, courseId: courseId)
    }
    
}
