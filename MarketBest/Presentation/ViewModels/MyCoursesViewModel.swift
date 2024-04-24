//
//  MyCoursesViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation
import Combine

class MyCoursesViewModel: ObservableObject {
    
    @Published var courses: [CourseModel] = []
    @Published var isLoading = false
    @Published var isLoadingMedia = false
    @Published var showNeedToLoginView = true
    @Published var userId: UUID?
    @Published var mediaItems: [CourseMediaItem] = []
    
    enum CourseStatusCategory: String, CaseIterable, Hashable, Identifiable {
        case waitingForAction = "Ждут действий"
        case active = "Активные"
        case archived = "Архив"
        
        var id: String { rawValue }
    }
    
    var categoriesToShow: [CourseStatusCategory] {
        get {
            return CourseStatusCategory.allCases.filter { category in
                !courses(for: category).isEmpty
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let fetchMyCoursesUseCase: FetchMyCoursesUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchCourseMediaUseCase: FetchCourseMediaUseCase
    
    init(
        fetchMyCoursesUseCase: FetchMyCoursesUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchCourseMediaUseCase: FetchCourseMediaUseCase,
        authStateManager: AuthStateManager) {
            self.fetchMyCoursesUseCase = fetchMyCoursesUseCase
            self.fetchCategoriesUseCase = fetchCategoriesUseCase
            self.fetchCourseMediaUseCase = fetchCourseMediaUseCase
            
            NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(clearCourses),
                        name: .didSignOutNotification,
                        object: nil)
            
            authStateManager.$currentUser
                .receive(on: RunLoop.main)
                .removeDuplicates() // Ensure we don't trigger the chain for the same user state
                .sink { [weak self] user in
                    guard let self = self else { return }
                    
                    self.showNeedToLoginView = (user == nil) // Display login view if user is nil
                    
                    if let user {
                        self.userId = user.id
                        Task {
                            await self.fetchMyCourses()
                        }
                    }
                }
                .store(in: &cancellables)
            
        }
    
    func fetchMyCourses() async {
        guard let userId else { return }
        guard !isLoading else { return }
        
        do {
            try await Task.sleep(seconds: 2)
            if courses.count == 0 {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
            }
            let courses = try await fetchMyCoursesUseCase.execute(userId: userId)
            print("courses are fetched")
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
                    self.fetchMedia(for: [updatedCourse])
                } else {
                    self.courses.append(updatedCourse)
                    updatedCourses.append(updatedCourse) // Collect new courses
                }

                updatedCourseIds.insert(course.id)
            }
            
            // Identify and remove courses that were deleted from the source but are still in the local model
            self.courses = self.courses.filter { updatedCourseIds.contains($0.id) }
            self.courses.sort { $0.updatedAt > $1.updatedAt }

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
                    let sortedMedia = response.sorted(by: { $0.order < $1.order })
                    DispatchQueue.main.async {
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
    
    func sortMediaIntoCourses() {
        var courseMediaDict = [UUID: [CourseMediaItem]]()

        for mediaItem in mediaItems {
            courseMediaDict[mediaItem.courseId, default: []].append(mediaItem)
        }

        for index in courses.indices {
            let sortedMedia = courseMediaDict[courses[index].id]?.sorted(by: { $0.order < $1.order }) ?? []
            courses[index].media = sortedMedia
        }
    }

    @objc private func clearCourses() {
        DispatchQueue.main.async {
            print("notification to clear data")
            self.courses = []
            self.mediaItems = []
            self.userId = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
                                                                
}

extension MyCoursesViewModel {

    var waitingForActionCourses: [CourseModel] {
        courses.filter { $0.status == .uncompleted || $0.status == .rejected }
    }

    var activeCourses: [CourseModel] {
        courses.filter { $0.status == .moderation || $0.status == .active }
    }

    var archivedCourses: [CourseModel] {
        courses.filter { $0.status == .archived }
    }
    
    func courses(for statusCategory: CourseStatusCategory) -> [CourseModel] {
        switch statusCategory {
        case .waitingForAction:
            return waitingForActionCourses
        case .active:
            return activeCourses
        case .archived:
            return archivedCourses
        }
    }
}
