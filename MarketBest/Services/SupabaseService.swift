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
    let tableName: String
    
    
    init(tableName: String, supabase: SupabaseClient) {
        self.tableName = tableName
        self.supabase = supabase
    }
    
    func fetchAll() async throws -> [T] {
        let response: [T] = try await supabase.database.from(tableName).select().execute().value
        return response
    }
    
    func fetchById(columnName: String, id: UUID) async throws -> [T]? {
        let response: [T] = try await supabase.database.from(tableName).select().eq(columnName, value: id).execute().value
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
}
