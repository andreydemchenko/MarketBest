//
//  UserRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

protocol UserRepository {
    func fetchCurrentUser() async throws -> UserModel?
    func updateUserRole(userId: String, newRole: UserRole) async throws
    func signOut() async throws
}
