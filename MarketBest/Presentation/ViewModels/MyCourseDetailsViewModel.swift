//
//  CourseViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation

class MyCourseDetailsViewModel: ObservableObject {
    
    @Published var course: CourseModel
    @Published var isLoading = false
    
    private let updateCourseStatusUseCase: UpdateCourseStatusUseCase
    private let deleteCourseUseCase: DeleteCourseUseCase
    private let deleteMediaItemUseCase: DeleteMediaItemUseCase
    private let authStateManager: AuthStateManager
    
    init(
        course: CourseModel,
        updateCourseStatusUseCase: UpdateCourseStatusUseCase,
        deleteCourseUseCase: DeleteCourseUseCase,
        deleteMediaItemUseCase: DeleteMediaItemUseCase,
        authStateManager: AuthStateManager
    ) {
        self.course = course
        self.updateCourseStatusUseCase = updateCourseStatusUseCase
        self.deleteCourseUseCase = deleteCourseUseCase
        self.deleteMediaItemUseCase = deleteMediaItemUseCase
        self.authStateManager = authStateManager
    }
    
    func addCourseToArchive() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            try await updateCourseStatusUseCase.execute(courseId: course.id, status: .archived)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("error in addCourseToArchive: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func publishCourse() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            let status: CourseStatus = authStateManager.canAccess(.publishCourse) ? .active : .moderation
            try await updateCourseStatusUseCase.execute(courseId: course.id, status: status)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("error in addCourseToArchive: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func deleteCourse() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            let group = DispatchGroup()
            
            for item in course.media {
                group.enter()
                Task {
                    do {
                        try await deleteMediaItemUseCase.execute(mediaItem: item)
                    } catch {
                        print("Failed to delete media item: \(error)")
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                print("media items have been removed")
            }
            try await deleteCourseUseCase.execute(id: course.id)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("error in addCourseToArchive: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
