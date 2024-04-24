//
//  CourseMediaRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

protocol CourseMediaRepository {
    func uploadMediaItem(fileData: Data, fileName: String, contentType: String) async throws -> URL?
    func createCourseMediaItem(media: CourseMediaItem) async throws
    func updateMediaItem(media: CourseMediaItem) async throws
    func removeMediaItem(fileName: String) async throws
    func deleteMediaItem(id: UUID) async throws
    func fetchCourseMedia(courseId: UUID) async throws -> [CourseMediaItem]
    func fetchMyMedia(userId: UUID) async throws -> [CourseMediaItem]
    func fetchAllMedia() async throws -> [CourseMediaItem]
    func fetchVideoDetails(for id: String) async throws -> YouTubeVideo
}
