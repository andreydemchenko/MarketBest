//
//  FavouritesRepositoryImpl.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

class FavouritesRepositoryImpl: FavouritesRepository {
    
    private let remoteDataSource: RemoteDataSource<FavouriteModel>
    
    init(remoteDataSource: RemoteDataSource<FavouriteModel>) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchFavourites(userId: UUID, courseIds: [UUID]?) async throws -> [FavouriteModel] {
        do {
            return try await remoteDataSource.fetchFavourites(userId: userId, courseIds: courseIds)
        } catch {
            throw error
        }
    }
    
    func addToFavourites(userId: UUID, courseId: UUID) async throws {
        do {
            let model = FavouriteModel(id: UUID(), userId: userId, courseId: courseId, createdAt: Date())
            try await remoteDataSource.create(model: model)
        } catch {
            throw error
        }
    }
    
    func removeFromFavourites(userId: UUID, courseId: UUID) async throws {
        do {
            try await remoteDataSource.removeFromFavourites(userId: userId, courseId: courseId)
        } catch {
            throw error
        }
    }
    
    
}
