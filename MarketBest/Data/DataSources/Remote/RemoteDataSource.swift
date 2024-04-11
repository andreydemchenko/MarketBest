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

    func deleteById(id: UUID) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        try await service.delete(id: id)
    }

    func fetchById(id: UUID) async throws -> [T]? {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.fetchById(columnName: "id", id: id)
    }
}

extension RemoteDataSource where T == UserModel {
    func fetchCurrentUser() async throws -> UserModel? {
        let currentUserId = try await supabaseClient.auth.session.user.id
        print("fetch user id \(currentUserId)")
        let user = try await fetchById(id: currentUserId)?.first
        return user
    }

    func updateUserRole(userId: UUID, newRole: UserRole) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.update(id: userId, fields: ["role": newRole.rawValue])
    }
    
    func signUp(email: String, password: String) async throws -> String? {
        do {
            let response = try await supabaseClient.auth.signUp(email: email, password: password)
            return response.user.id.uuidString
        } catch let error {
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws -> String? {
        do {
            let response = try await supabaseClient.auth.signIn(email: email, password: password)
            return response.user.id.uuidString
        } catch let error {
            throw error
        }
    }

    func signOut() async throws {
        try await supabaseClient.auth.signOut()
    }
}

extension RemoteDataSource where T == CourseModel {
    
    func updateCourseStatus(courseId: UUID, status: CourseStatus) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.update(id: courseId, fields: ["status": status.rawValue])
    }
    
    func fetchMyCourses(userId: UUID) async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient)
        return try await service.fetchById(columnName: "user_id", id: userId) ?? []
    }
}
