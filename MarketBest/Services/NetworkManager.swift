//
//  NetworkManager.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import Supabase
import Storage

class NetworkManager {
    
//    let credentialManager: CredentialManager
//    
//    init(credentialManager: CredentialManager) {
//        self.credentialManager = credentialManager
//    }
    
    private var supabaseUrl: URL {
        return Constants.supabaseUrl
    }
    
    var supabase: SupabaseClient {
        //let supabaseKey = credentialManager.getSupabaseKey()
        return SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
    
    private var supabaseKey: String {
        return Constants.supabaseKey
    }
    
    private var supabaseServiceKey: String {
        return Constants.supabaseServiceKey
    }
    
    func storageClient() -> SupabaseStorageClient {
        //        guard let jwt = try? await supabase.auth.session.accessToken else {
        //            print("couldn't access auth")
        //            return nil}
        return SupabaseStorageClient(
            configuration: StorageClientConfiguration(url: URL(string: "\(supabaseUrl)/storage/v1")!, headers: [
                "Authorization": "Bearer \(supabaseServiceKey)",
                "apikey": supabaseKey,
            ])
        )
    }
}
