//
//  FetchFavouritesUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

class FetchFavouritesUseCase {
    
    private let repository: FavouritesRepository
    
    init(repository: FavouritesRepository) {
        self.repository = repository
    }
    
    func execute(userId: UUID, courseIds: [UUID]? = nil) async throws -> [FavouriteModel] {
        return try await repository.fetchFavourites(userId: userId, courseIds: courseIds)
    }
    
}
