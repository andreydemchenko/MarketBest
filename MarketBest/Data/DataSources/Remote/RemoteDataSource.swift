//
//  RemoteDataSource.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import Supabase

class RemoteDataSource<T: SupabaseModel> {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func fetchAll() async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.fetchAll()
    }

    func create(model: T) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        try await service.create(item: model)
    }

    func update(model: T) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        try await service.update(id: model.id, fields: model)
    }

    func deleteById(id: String) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        try await service.delete(id: id)
    }

    func fetchById(id: String) async throws -> T? {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.fetchById(columnName: "id", id: id) as? T
    }
}

extension RemoteDataSource where T == UserModel {
    func fetchCurrentUser() async throws -> UserModel? {
        let currentUserId = try await supabaseClient.auth.session.user.id.uuidString
        let user = try await fetchById(id: currentUserId)
        return user
    }

    func updateUserRole(userId: String, newRole: UserRole) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.update(id: userId, fields: ["role": newRole.rawValue])
    }

    func signOut() async throws {
        try await supabaseClient.auth.signOut()
    }
}

