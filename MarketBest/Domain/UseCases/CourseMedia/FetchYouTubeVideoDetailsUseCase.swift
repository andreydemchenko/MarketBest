//
//  FetchYouTubeVideoDetailsUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 18.04.2024.
//

import Foundation

class FetchYouTubeVideoDetailsUseCase {
    let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(videoURL: String) async throws -> YouTubeVideo {
        guard let videoID = YouTubeURLParser.extractID(from: videoURL) else {
            throw URLError(.unsupportedURL)
        }
        return try await repository.fetchVideoDetails(for: videoID)
    }
}
