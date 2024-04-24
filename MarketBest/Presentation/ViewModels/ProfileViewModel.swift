//
//  ProfileViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation
import UIKit

class ProfileViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var isLoadingMedia = false
    @Published var isLoadingImage: Bool = false
    @Published var image: UIImage?
    @Published var courses: [CourseModel] = []
    
    private let signOutUseCase: SignOutUseCase
    private let fetchCoursesByStatusUseCase: FetchCoursesByStatusUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchCourseMediaUseCase: FetchCourseMediaUseCase
    let authStateManager: AuthStateManager
    
    init(
        signOutUseCase: SignOutUseCase,
        fetchCoursesByStatusUseCase: FetchCoursesByStatusUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchCourseMediaUseCase: FetchCourseMediaUseCase,
        authStateManager: AuthStateManager
    ) {
        self.signOutUseCase = signOutUseCase
        self.fetchCoursesByStatusUseCase = fetchCoursesByStatusUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchCourseMediaUseCase = fetchCourseMediaUseCase
        self.authStateManager = authStateManager
    }
    
    func signOut(onSignedOut: () -> Void) async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            try await Task.sleep(seconds: 2)
    
            try await signOutUseCase.execute()
            DispatchQueue.main.async {
                self.resetData()
            }
            onSignedOut()
        } catch {
            print("sign out error: \(error)")
        }
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    private func resetData() {
        image = nil
        isLoadingMedia = false
        isLoadingImage = false
        courses = []
        NotificationCenter.default.post(name: .didSignOutNotification, object: nil)
    }

    
    func loadImage(user: UserModel) async {
        guard image == nil || user.imageUrl == nil || ((user.imageUrl?.isEmpty) != nil) else {
            return
        }
        DispatchQueue.main.async {
            self.isLoadingImage = true
        }
        do {
            if let urlStr = user.imageUrl, let url = URL(string: urlStr) {
                let (data, _) = try await URLSession.shared.data(from: url)
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                    self.isLoadingImage = false
                }
            } else {
                DispatchQueue.main.async {
                    self.image = nil
                    self.isLoadingImage = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoadingImage = false
            }
            print("Error loading user image: \(error.localizedDescription)")
        }
    }
    
    func fetchModerationCourses() async {
        guard !isLoading else { return }
        
        do {
//            if courses.count == 0 {
//                DispatchQueue.main.async {
//                    self.isLoading = true
//                }
//            }
            let courses = try await fetchCoursesByStatusUseCase.execute(status: .moderation)
            await fetchCategoriesAndAssign(courses: courses)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("error in fetchMyCourses: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func fetchCategoriesAndAssign(courses: [CourseModel]) async {
        let categoryIds = Set(courses.map { $0.categoryId })
        let subCategories = await fetchCategories(categoryIds: Array(categoryIds))
        let parentCategoryIds = Set(subCategories.compactMap { $0.parentCategoryId })
        let parentCategories = await fetchCategories(categoryIds: Array(parentCategoryIds))

        DispatchQueue.main.async {
            let subCategoryDictionary = Dictionary(uniqueKeysWithValues: subCategories.map { ($0.id, $0) })
            let parentCategoryDictionary = Dictionary(uniqueKeysWithValues: parentCategories.map { ($0.id, $0) })
            
            var updatedCourses = [CourseModel]()
            var updatedCourseIds = Set<UUID>()

            for course in courses {
                var updatedCourse = course
                if let subCategory = subCategoryDictionary[course.categoryId] {
                    updatedCourse.categoryName = subCategory.name
                    updatedCourse.categoryIconUrl = subCategory.iconUrl
                    
                    if let parentCategory = parentCategoryDictionary[subCategory.parentCategoryId ?? UUID()] {
                        updatedCourse.parentCategoryName = parentCategory.name
                        updatedCourse.parentCategoryIconUrl = parentCategory.iconUrl
                    }
                }
                
                if let index = self.courses.firstIndex(where: { $0.id == course.id }) {
                    if self.courses[index] != updatedCourse {
                        self.courses[index] = updatedCourse
                        updatedCourses.append(updatedCourse) // Collect updated courses
                    }
                } else {
                    self.courses.append(updatedCourse)
                    updatedCourses.append(updatedCourse) // Collect new courses
                }

                updatedCourseIds.insert(course.id)
            }
            
            // Identify and remove courses that were deleted from the source but are still in the local model
            self.courses = self.courses.filter { updatedCourseIds.contains($0.id) }
            self.courses.sort { $0.createdAt < $1.createdAt }

            if !updatedCourses.isEmpty {
                self.fetchMedia(for: updatedCourses)
            }
        }
    }
    
    func fetchCategories(categoryIds: [UUID]) async -> [CategoryModel] {
        do {
            return try await fetchCategoriesUseCase.execute(categoryIds: categoryIds)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func fetchMedia(for updatedCourses: [CourseModel]) {
        guard !updatedCourses.isEmpty else { return }
        let group = DispatchGroup()
        isLoadingMedia = true

        for course in updatedCourses {
            group.enter()
            Task {
                do {
                    let response = try await fetchCourseMediaUseCase.execute(courseId: course.id)
                    DispatchQueue.main.async {
                        let sortedMedia = response.sorted(by: { $0.order < $1.order })
                        if let index = self.courses.firstIndex(where: { $0.id == course.id }) {
                            self.courses[index].media = sortedMedia
                        }
                    }
                } catch {
                    print("Failed to fetch media items: \(error)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.isLoadingMedia = false
        }
    }
}
