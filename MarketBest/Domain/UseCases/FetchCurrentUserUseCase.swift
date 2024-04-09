//
//  FetchCurrentUserUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

class FetchCurrentUserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> UserModel? {
        return try await repository.fetchCurrentUser()
    }
}
