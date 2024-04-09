//
//  NetworkManager.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import Supabase

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
}
