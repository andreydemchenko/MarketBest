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
    private let storageClient: SupabaseStorageClient

    init(supabaseClient: SupabaseClient, storageClient: SupabaseStorageClient) {
        self.supabaseClient = supabaseClient
        self.storageClient = storageClient
    }

    func fetchAll() async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        return try await service.fetchAll()
    }

    func create(model: T) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        try await service.create(item: model)
    }

    func update(model: T) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        try await service.update(id: model.id, fields: model)
    }

    func deleteById(id: UUID) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        try await service.delete(id: id)
    }

    func fetchByColumn(column: String, value: any URLQueryRepresentable) async throws -> [T]? {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        return try await service.fetchByColumn(columnName: column, value: value)
    }
    
    func fetchByIds(ids: [UUID]) async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        return try await service.fetchByIDs(columnName: "id", ids: ids)
    }
    
}

extension RemoteDataSource where T == UserModel {
    func fetchCurrentUser() async throws -> UserModel? {
        let currentUserId = try await supabaseClient.auth.session.user.id
        let user = try await fetchByColumn(column: "id", value: currentUserId)?.first
        return user
    }

    func updateUserRole(userId: UUID, newRole: UserRole) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
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
    
    func fetchCourses(categoryIds: [UUID]? = nil, name: String? = nil) async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        
        var criteria = [String: [URLQueryRepresentable]]()
        
        if let categoryIds, !categoryIds.isEmpty {
            criteria["category_id"] = categoryIds
        }
        
        if let name, !name.isEmpty {
            criteria["name"] = [name]
        }
        
        // Identify fields that should be treated as UUIDs
        let uuidFields = ["category_id"] // Specify fields that are UUIDs
        
        if !criteria.isEmpty {
            return try await service.fetchByCriteria(criteria: criteria, uuidFields: uuidFields) ?? []
        } else {
            return try await service.fetchAll()
        }
    }

    
    func updateCourseStatus(courseId: UUID, status: CourseStatus) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        let currentDate = Date().toSupabaseString
        return try await service.update(id: courseId, fields: ["status": status.rawValue, "updated_at": currentDate])
    }
    
    func fetchMyCourses(userId: UUID) async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        return try await service.fetchByColumn(columnName: "user_id", value: userId) ?? []
    }
    
    func fetchCoursesByStatus(status: CourseStatus) async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        return try await service.fetchByColumn(columnName: "status", value: status.rawValue) ?? []
    }
    
}

extension RemoteDataSource where T == CourseMediaItem {
    
    func uploadMediaItem(fileData: Data, fileName: String, contentType: String) async throws -> URL? {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)      
        return try await service.uploudFile(fileData: fileData, bucketName: "courses", fileName: fileName, contentType: contentType)
    }
    
    func removeMediaItem(fileName: String) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        return try await service.removeFile(bucketName: "courses", fileName: fileName)
    }
    
}

extension RemoteDataSource where T == FavouriteModel {
    
    func fetchFavourites(userId: UUID, courseIds: [UUID]? = nil) async throws -> [T] {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        
        if let courseIds, !courseIds.isEmpty {
            let criteria = ["user_id": [userId], "course_id": courseIds]
            let uuidFields = ["user_id", "course_id"]
            return try await service.fetchByCriteria(criteria: criteria, uuidFields: uuidFields) ?? []
        } else {
            return try await service.fetchByColumn(columnName: "user_id", value: userId) ?? []
        }
    }
    
    func removeFromFavourites(userId: UUID, courseId: UUID) async throws {
        let service = SupabaseService<T>(tableName: T.tableName, supabase: supabaseClient, storageClient: storageClient)
        
        let criteria = ["user_id": [userId], "course_id": [courseId]]
        let uuidFields = ["user_id", "course_id"]
        let models = try await service.fetchByCriteria(criteria: criteria, uuidFields: uuidFields)
        
        if let model = models?.first {
            try await service.delete(id: model.id)
        } else {
            throw NSError(domain: "RemoteDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "Favorite not found"])
        }
    }
}
