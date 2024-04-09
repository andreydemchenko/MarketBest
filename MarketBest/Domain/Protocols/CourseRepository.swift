//
//  CourseRepository.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

protocol CourseRepository {
    func fetchCourses() async throws -> [CourseModel]
}
