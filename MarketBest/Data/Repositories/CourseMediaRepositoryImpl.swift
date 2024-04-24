//
//  CourseMediaRepositoryImpl.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class CourseMediaRepositoryImpl: CourseMediaRepository {
    
    private let remoteDataSource: RemoteDataSource<CourseMediaItem>
    //private let localDataSource: LocalDataSource<CourseMediaEntity>
    
    init(remoteDataSource: RemoteDataSource<CourseMediaItem>) {
        self.remoteDataSource = remoteDataSource
        //self.localDataSource = localDataSource
    }
    
    func uploadMediaItem(fileData: Data, fileName: String, contentType: String) async throws -> URL? {
        do {
            return try await remoteDataSource.uploadMediaItem(fileData: fileData, fileName: fileName, contentType: contentType)
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func createCourseMediaItem(media: CourseMediaItem) async throws {
        do {
            try await remoteDataSource.create(model: media)
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func updateMediaItem(media: CourseMediaItem) async throws {
        do {
            try await remoteDataSource.update(model: media)
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func removeMediaItem(fileName: String) async throws {
        do {
            try await remoteDataSource.removeMediaItem(fileName: fileName)
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func deleteMediaItem(id: UUID) async throws {
        do {
            try await remoteDataSource.deleteById(id: id)
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func fetchCourseMedia(courseId: UUID) async throws -> [CourseMediaItem] {
        do {
            return try await remoteDataSource.fetchByColumn(column: "course_id", value: courseId) ?? []
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func fetchMyMedia(userId: UUID) async throws -> [CourseMediaItem] {
        do {
            return try await remoteDataSource.fetchByColumn(column: "user_id", value: userId) ?? []
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func fetchAllMedia() async throws -> [CourseMediaItem] {
        do {
            return try await remoteDataSource.fetchAll()
            //try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
    
    func fetchVideoDetails(for id: String) async throws -> YouTubeVideo {
        let apiKey = Constants.youtubeApiKey
        let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=\(id)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(YouTubeAPIResponse.self, from: data)
        guard let details = response.items.first else {
            throw URLError(.cannotDecodeContentData)
        }
        return YouTubeVideo(title: details.snippet.title, thumbnailURL: URL(string: details.snippet.thumbnails.medium.url)!)
    }
    
}
