//
//  HomeViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 22.04.2024.
//

import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var categorizedData: [(parent: CategoryModel, children: [CategoryModel])] = []
    @Published var courses: [CourseModel] = []
    @Published var searchQuery: String = ""
    @Published var searchCategories: [(parent: CategoryModel, child: CategoryModel)] = []
    @Published var popularCategories: [(parent: CategoryModel, child: CategoryModel)] = []
    @Published var selectedCategoryIds: Set<UUID> = []
    @Published var selectedParentCategoryId: UUID?
    @Published var user: UserModel?
    @Published var isLoadingMedia = false
    @Published var hasLoadedMedia = false
    
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchCoursesUseCase: FetchCoursesUseCase
    private let fetchCourseMediaUseCase: FetchCourseMediaUseCase
    private let favoritesManager: FavoritesManager
    private let authStateManager: AuthStateManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchCoursesUseCase: FetchCoursesUseCase,
        fetchCourseMediaUseCase: FetchCourseMediaUseCase,
        favoritesManager: FavoritesManager,
        authStateManager: AuthStateManager
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchCoursesUseCase = fetchCoursesUseCase
        self.fetchCourseMediaUseCase = fetchCourseMediaUseCase
        self.favoritesManager = favoritesManager
        self.authStateManager = authStateManager
        
        setupBindings()
        
        Task {
            await fetchCategories()
        }
    }
    
    func clearData() {
        withAnimation {
            searchQuery = ""
            courses = []
            selectedParentCategoryId = nil
            selectedCategoryIds = []
            hasLoadedMedia = false
        }
    }
    
    func setupBindings() {
        authStateManager.$currentUser
            .compactMap { $0 }
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
        
        $searchQuery
            .removeDuplicates()
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self else { return }
                Task {
                    await self.searchCategoriesAndCourses()
                }
            }
            .store(in: &cancellables)
    }
    
    func searchCategoriesAndCourses() async {
        guard !searchQuery.isEmpty, searchQuery.count > 2 else {
            searchCategories.removeAll()
            return
        }
        
        do {
            let fetchedCourses = try await fetchCoursesUseCase.execute(name: searchQuery)
            DispatchQueue.main.async {
                self.filterCategories(for: fetchedCourses)
            }
        } catch {
            print("Error fetching courses by name: \(error)")
        }
    }
    
    func searchCourses() async {
        guard !searchQuery.isEmpty else {
            return
        }
        
        do {
            let fetchedCourses = try await fetchCoursesUseCase.execute(name: searchQuery)
            await fetchCategoriesAndAssign(courses: fetchedCourses)
            DispatchQueue.main.async {
                self.fetchFavorites()
            }
        } catch {
            print("Error fetching courses by name: \(error)")
        }
    }
    
    private func filterCategories(for courses: [CourseModel]) {
        let categoryIds = Set(courses.map { $0.categoryId })
        
        withAnimation {
            searchCategories.removeAll()
        }
        
        for categoryData in categorizedData {
            for child in categoryData.children {
                if categoryIds.contains(child.id) {
                    // Check to ensure this child hasn't already been added
                    if !searchCategories.contains(where: { $0.child.id == child.id }) {
                        // Append the parent and child tuple to the searchCategories
                        withAnimation {
                            searchCategories.append((parent: categoryData.parent, child: child))
                        }
                    }
                }
            }
        }
    }
    
    func fetchCategories() async {
        do {
            let response = try await fetchCategoriesUseCase.execute()
            DispatchQueue.main.async {
                self.organizeCategories(categories: response)
            }
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    private func organizeCategories(categories: [CategoryModel]) {
        var parentCategories = [UUID: CategoryModel]()
        var childCategories = [UUID: [CategoryModel]]()
        
        for category in categories {
            if let parentId = category.parentCategoryId {
                childCategories[parentId, default: []].append(category)
            } else {
                parentCategories[category.id] = category
            }
        }
        
        self.categorizedData = parentCategories.map { (id, parent) -> (CategoryModel, [CategoryModel]) in
            return (parent, childCategories[id, default: []])
        }.sorted { $0.0.name < $1.0.name }
        
        
        // Setting up mock popular categories
        self.popularCategories = parentCategories.compactMap { id, parent -> (parent: CategoryModel, child: CategoryModel)? in
            guard let children = childCategories[id], !children.isEmpty else { return nil }
            return (parent: parent, child: children.randomElement()!)
        }.sorted { $0.parent.name < $1.parent.name }
    }
    
    func categoryClicked(categoryId: UUID, isParent: Bool, childrenIds: [UUID], parentId: UUID?, isFromSearch: Bool = false) {
        if isParent {
            if selectedCategoryIds.contains(categoryId) {
                // Unselect parent and all its children
                selectedCategoryIds.remove(categoryId)
                childrenIds.forEach { selectedCategoryIds.remove($0) }
                if selectedParentCategoryId == categoryId {
                    selectedParentCategoryId = nil // Hide children if parent is deselected
                }
            } else {
                // Select parent and all its children
                selectedCategoryIds.insert(categoryId)
                childrenIds.forEach { selectedCategoryIds.insert($0) }
                selectedParentCategoryId = categoryId // Ensure children are shown
            }
        } else {
            // Toggle the selection of a child category
            if selectedCategoryIds.contains(categoryId), !isFromSearch {
                selectedCategoryIds.remove(categoryId)
            } else {
                selectedCategoryIds.insert(categoryId)
                // If parent is not selected when selecting a child, select the parent as well
                if let parentId, !selectedCategoryIds.contains(parentId) {
                    selectedCategoryIds.insert(parentId)
                    selectedParentCategoryId = parentId
                }
            }

//            if let parentId {
//                let siblingIds = childrenIds.filter { $0 != categoryId } // Exclude current child for sibling check
//                let allSiblingsSelected = siblingIds.allSatisfy { selectedCategoryIds.contains($0) }
//                if allSiblingsSelected {
//                    selectedCategoryIds.insert(parentId)
//                    selectedParentCategory = parentId
//                }
//            }
        }
        
        Task {
            await fetchCoursesForSelectedCategories()
        }
    }
    
    func fetchCoursesForSelectedCategories() async {
        var idsToFetch: [UUID] = []
        
        for categoryId in selectedCategoryIds {
            // Check if the category is a parent by seeing if it has children in categorizedData
            if let parentData = categorizedData.first(where: { $0.parent.id == categoryId }) {
                // If any child is also selected, only add those children, else add all children
                let selectedChildrenIds = parentData.children.filter { selectedCategoryIds.contains($0.id) }.map { $0.id }
                if selectedChildrenIds.isEmpty {
                    // No specific children selected, add all children
                    idsToFetch.append(contentsOf: parentData.children.map { $0.id })
                } else {
                    // Specific children are selected, add only those
                    idsToFetch.append(contentsOf: selectedChildrenIds)
                }
            } else {
                // It's a child category; add its ID
                idsToFetch.append(categoryId)
            }
        }
        
        // Remove duplicates
        idsToFetch = Array(Set(idsToFetch))
        
        do {
            var name: String? = nil
            if !searchQuery.isEmpty {
                name = searchQuery
            }
            let courses = try await fetchCoursesUseCase.execute(categoryIds: idsToFetch, name: name)
            await fetchCategoriesAndAssign(courses: courses)
            DispatchQueue.main.async {
                //self.courses = courses
                self.fetchFavorites()
            }
            
        } catch {
            print("Error fetching courses for categories: \(error)")
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
                        withAnimation {
                            self.courses[index] = updatedCourse
                        }
                        updatedCourses.append(updatedCourse) // Collect updated courses
                    }
                    self.fetchMedia(for: [updatedCourse])
                } else {
                    withAnimation {
                        self.courses.append(updatedCourse)
                    }
                    updatedCourses.append(updatedCourse) // Collect new courses
                }
                
                updatedCourseIds.insert(course.id)
            }
            
            // Identify and remove courses that were deleted from the source but are still in the local model
            withAnimation {
                self.courses = self.courses.filter { updatedCourseIds.contains($0.id) }
                self.courses.sort { $0.updatedAt > $1.updatedAt }
            }
            
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
        guard !courses.isEmpty else { return }
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
            self.hasLoadedMedia = true
        }
    }
    
    func fetchFavorites() {
        withAnimation {
            self.courses = self.courses.map { course -> CourseModel in
                var updatedCourse = course
                updatedCourse.isMyFavourite = self.favoritesManager.favoriteCourses.contains(course.id)
                return updatedCourse
            }
        }
    }
    
    func toggleFavorite(courseId: UUID) {
        favoritesManager.toggleFavorite(
            courseId: courseId,
            onAdded:  {
                if let index = self.courses.firstIndex(where: { $0.id == courseId }) {
                    self.courses[index].isMyFavourite = false
                }
            },
            onRemoved: {
                if let index = self.courses.firstIndex(where: { $0.id == courseId }) {
                    self.courses[index].isMyFavourite = true
                }
            })
    }
    
    func isFavouriteCourse(id: UUID) -> Bool {
        return favoritesManager.favoriteCourses.contains(id)
    }
    
    func performGlobalSearch() {
        selectedCategoryIds = []
        selectedParentCategoryId = nil
        Task {
            await searchCourses()
        }
    }
}
