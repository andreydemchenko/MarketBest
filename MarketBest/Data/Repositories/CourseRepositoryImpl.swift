//
//  CourseRepositoryImpl.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

class CourseRepositoryImpl: CourseRepository {
    private let remoteDataSource: RemoteDataSource<CourseModel>
    private let localDataSource: LocalDataSource<CourseEntity>
    
    init(remoteDataSource: RemoteDataSource<CourseModel>, localDataSource: LocalDataSource<CourseEntity>) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchCourses() async throws -> [CourseModel] {
        do {
            // Attempt to fetch courses from the remote data source
            let courses = try await remoteDataSource.fetchAll()
            try await localDataSource.save(models: courses)
            return courses
        } catch {
            // On failure, attempt to fetch courses from the local data source
            let localCourses = try await localDataSource.fetchAll()
            return localCourses
        }
    }
}
