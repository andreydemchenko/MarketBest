//
//  UpdateUserUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

class UpdateUserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(user: UserModel) async throws {
        return try await repository.updateUser(user: user)
    }
}
