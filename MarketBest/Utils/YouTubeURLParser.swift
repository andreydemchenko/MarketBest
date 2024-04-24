//
//  YouTubeURLParser.swift
//  MarketBest
//
//  Created by Macbook Pro on 18.04.2024.
//

import Foundation

class YouTubeURLParser {
    static func extractID(from url: String) -> String? {
        if url.contains("youtube.com") {
            return URLComponents(string: url)?.queryItems?.first(where: { $0.name == "v" })?.value
        } else if url.contains("youtu.be") {
            return URL(string: url)?.lastPathComponent
        }
        return nil
    }
}
