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
    
    func fetchByCriteria(criteria: [String: [URLQueryRepresentable]]) async throws -> [T]? {
        var databaseQuery = supabase.database.from(tableName).select()
        
        for (field, values) in criteria {
            if values.count == 1 {
                databaseQuery = databaseQuery.eq(field, value: values.first!)
            } else {
                databaseQuery = databaseQuery.in(field, value: values)
            }
        }
        
        let response: [T] = try await databaseQuery.execute().value
        return response
    }
}
