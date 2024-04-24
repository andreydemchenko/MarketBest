//
//  FavouritesRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

protocol FavouritesRepository {
    func fetchFavourites(userId: UUID, courseIds: [UUID]?) async throws -> [FavouriteModel]
    func addToFavourites(userId: UUID, courseId: UUID) async throws
    func removeFromFavourites(userId: UUID, courseId: UUID) async throws
}
