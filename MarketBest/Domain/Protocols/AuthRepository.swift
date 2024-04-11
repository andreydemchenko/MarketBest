//
//  AuthRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

protocol AuthRepository {
    func signUp(email: String, password: String) async throws -> String?
    func signIn(email: String, password: String) async throws -> String?
    func signOut() async throws
}
