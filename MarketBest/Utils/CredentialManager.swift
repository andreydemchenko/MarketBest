//
//  CredentialManager.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import KeychainAccess

class CredentialManager {
    static let shared = CredentialManager()
    private let keychain = Keychain(service: "ru.turbopro.MarketBest")
    
    private init() {}
    
    func getSupabaseKey() -> String {
        return keychain["supabaseKey"] ?? ""
    }
    
    func getSupabaseServiceKey() -> String {
        return keychain["supabaseServiceKey"] ?? ""
    }
    
    func setSupabaseKey(_ key: String) {
        keychain["supabaseKey"] = key
    }
    
    func setSupabaseServiceKey(_ key: String) {
        keychain["supabaseServiceKey"] = key
    }
    
}
