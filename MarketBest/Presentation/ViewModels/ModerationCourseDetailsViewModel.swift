//
//  ModerationCourseDetailsViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import Foundation

class ModerationCourseDetailsViewModel: ObservableObject {
    
    @Published var course: CourseModel
    @Published var isLoading = false
    
    private let updateCourseStatus: UpdateCourseStatusUseCase
    
    init(
        course: CourseModel,
        updateCourseStatusUseCase: UpdateCourseStatusUseCase
    ) {
        self.course = course
        self.updateCourseStatus = updateCourseStatusUseCase
    }
    
    func rejectCourse() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            try await updateCourseStatus.execute(courseId: course.id, status: .rejected)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("error in reject course: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func acceptCourse() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            try await updateCourseStatus.execute(courseId: course.id, status: .active)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("error in accept course: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
