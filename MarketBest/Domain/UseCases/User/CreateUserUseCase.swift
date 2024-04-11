//
//  CreateUserUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

class CreateUserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(user: UserModel) async throws {
        return try await repository.createUser(user: user)
    }
}
