//
//  Constants.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

struct Constants {
    static let buildConfig = BuildConfiguration.shared
//    static let privacyUrl = URL(string: "https://makesure.app/confidentiality")
//    static let helpUrl = URL(string: "https://makesure.app/faq")
//    static let helpEngUrl = URL(string: "https://makesure.app/faq_eng")
//    static let aboutUrl = URL(string: "https://makesure.app/about")
//    static let agreementUrl = URL(string: "https://makesure.app/license_agreement")
    static let supabaseUrl = URL(string: buildConfig.value(forKey: "SUPABASE_URL") ?? "http://default-supabase-url.com")!
    static let supabaseKey = buildConfig.value(forKey: "SUPABASE_KEY") ?? ""
    static let supabaseServiceKey = buildConfig.value(forKey: "SUPABASE_SERVICE_KEY") ?? ""
    static let youtubeApiKey = buildConfig.value(forKey: "YOUTUBE_API_KEY") ?? ""
}
