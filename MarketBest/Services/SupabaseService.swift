//
//  SupabaseService.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import Supabase

class SupabaseService<T: Codable> {
    
    let supabase: SupabaseClient
    let storageClient: SupabaseStorageClient
    let tableName: String
    
    
    init(tableName: String, supabase: SupabaseClient, storageClient: SupabaseStorageClient) {
        self.tableName = tableName
        self.supabase = supabase
        self.storageClient = storageClient
    }
    
    func fetchAll() async throws -> [T] {
        let response: [T] = try await supabase.database.from(tableName).select().execute().value
        return response
    }
    
    
    func fetchByColumn(columnName: String, value: any URLQueryRepresentable) async throws -> [T]? {
        let response: [T] = try await supabase.database.from(tableName).select().eq(columnName, value: value).execute().value
        return response
    }
    
    func fetchByIDs(columnName: String, ids: [UUID]) async throws -> [T] {
        let response: [T] = try await supabase.database.from(tableName)
                              .select()
                              .in(columnName, value: ids)
                              .execute().value
        return response
    }
    
    func create(item: T) async throws {
        try await supabase.database.from(tableName).insert(item).execute().value
    }
    
    func update<U: Encodable>(id: UUID, fields: U) async throws {
        try await supabase.database.from(tableName).update(fields).eq("id", value: id).execute().value
    }
    
    func delete(id: UUID) async throws {
        try await supabase.database.from(tableName).delete().eq("id", value: id).execute()
    }
    
    func uploudFile(fileData: Data, bucketName: String, fileName: String, contentType: String) async throws -> URL? {
        
        try await storageClient
            .from(bucketName)
            .upload(path: fileName, file: fileData, options: FileOptions(cacheControl: "3600"))
        
        let secondsInYear = 31536000
        let signedURL = try await storageClient
          .from(bucketName)
          .createSignedURL(path: fileName, expiresIn: secondsInYear * 3)
        
        return signedURL
    }
    
    func removeFile(bucketName: String, fileName: String) async throws {
        let _ = try await storageClient
            .from(bucketName)
            .remove(paths: [fileName])
    }
    
    func fetchByCriteria(criteria: [String: [URLQueryRepresentable]], uuidFields: [String] = []) async throws -> [T]? {
        var databaseQuery = supabase.database.from(tableName).select()

        for (field, values) in criteria {
            if uuidFields.contains(field) {
                // Use 'in' operator if the field is a UUID and has multiple values
                if values.count > 1 {
                    databaseQuery = databaseQuery.in(field, value: values)
                } else if let firstValue = values.first {
                    databaseQuery = databaseQuery.eq(field, value: firstValue)
                }
            } else {
                // Assume field is a string, use ilike for all values
                for value in values {
                    databaseQuery = databaseQuery.ilike(field, value: "%\(value)%")
                }
            }
        }
        
        let response: [T] = try await databaseQuery.execute().value
        return response
    }
    
//    func fetchByCriteria(criteria: [String: [URLQueryRepresentable]], isEqual: Bool) async throws -> [T]? {
//        var databaseQuery = supabase.database.from(tableName).select()
//
//        for (field, values) in criteria {
//            if values.count == 1 {
//                // Assume fields in criteria with single values are UUIDs needing exact matches
//                let value = values.first!
//                if isEqual {
//                    databaseQuery = databaseQuery.eq(field, value: value)
//                } else {
//                    databaseQuery = databaseQuery.ilike(field, value: "%\(value)%")
//                }
//            } else if values.count > 1 {
//                // Use the 'in' operator for fields that are likely UUIDs and have multiple values
//                databaseQuery = databaseQuery.in(field, value: values)
//            } else {
//                // For any other case, particularly for text searches, consider using 'ilike'
//                for value in values {
//                    databaseQuery = databaseQuery.ilike(field, value: "%\(value)%")
//                }
//            }
//        }
//        
//        let response: [T] = try await databaseQuery.execute().value
//        return response
//    }



}
