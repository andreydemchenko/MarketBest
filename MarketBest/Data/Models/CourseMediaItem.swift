//
//  CourseMediaItem.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

struct CourseMediaItem: SupabaseModel, IdentifiableModel, Identifiable {
    
    static let tableName = "course_media"
    
    let id: UUID
    var courseId: UUID
    let name: String?
    var url: String
    var videoUrl: String?
    var order: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, courseId = "course_id", name, url, videoUrl = "video_url", order, createdAt = "created_at"
    }
}

struct YouTubeVideo: Decodable {
    let title: String
    let thumbnailURL: URL
}

struct YouTubeAPIResponse: Decodable {
    let items: [VideoDetails]
}

struct VideoDetails: Decodable {
    let snippet: VideoSnippet
}

struct VideoSnippet: Decodable {
    let title: String
    let thumbnails: VideoThumbnails
}

struct VideoThumbnails: Decodable {
    let medium: VideoThumbnailDetail
}

struct VideoThumbnailDetail: Decodable {
    let url: String
}
