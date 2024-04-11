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
            try await localDataSource.saveOrUpdate(models: courses)
            return courses
        } catch {
            // On failure, attempt to fetch courses from the local data source
            let localCourses = try await localDataSource.fetchAll()
            return localCourses
        }
    }
    
    func fetchMyCourses(userId: UUID) async throws -> [CourseModel] {
        do {
            let courses = try await remoteDataSource.fetchMyCourses(userId: userId)
            print("fetchMyCourses, user id = \(userId) courses = \(courses)")
            try await localDataSource.saveOrUpdate(models: courses)
            return courses
        } catch {
            print("fetchMyCourses, error: \(error)")
            let localCourses = try await localDataSource.fetchMyCourses(userId: userId)
            return localCourses
        }
    }
    
    func createCourse(course: CourseModel) async throws {
        do {
            try await remoteDataSource.create(model: course)
            try await localDataSource.create(model: course)
        } catch {
            throw error
        }
    }
    
    func editCourse(course: CourseModel) async throws {
        do {
            try await remoteDataSource.update(model: course)
            try await localDataSource.update(model: course)
        } catch {
            throw error
        }
    }
    
    func updateCourseStatus(id: UUID, status: CourseStatus) async throws {
        do {
            try await remoteDataSource.updateCourseStatus(courseId: id, status: status)
            try await localDataSource.updateCourseStatus(id: id, status: status)
        } catch {
            throw error
        }
    }
}
