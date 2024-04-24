//
//  CourseRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

protocol CourseRepository {
    func fetchCoursesByStatus(status: CourseStatus) async throws -> [CourseModel]
    func fetchCourses(categoryIds: [UUID]?) async throws -> [CourseModel]
    func fetchMyCourses(userId: UUID) async throws -> [CourseModel]
    func createCourse(course: CourseModel) async throws
    func editCourse(course: CourseModel) async throws
    func updateCourseStatus(id: UUID, status: CourseStatus) async throws
    func deleteCourse(id: UUID) async throws
}
