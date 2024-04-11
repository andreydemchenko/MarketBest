//
//  UserRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

protocol UserRepository {
    func createUser(user: UserModel) async throws
    func updateUser(user: UserModel) async throws
    func fetchCurrentUser() async throws -> UserModel?
    func updateUserRole(userId: UUID, newRole: UserRole) async throws
}
