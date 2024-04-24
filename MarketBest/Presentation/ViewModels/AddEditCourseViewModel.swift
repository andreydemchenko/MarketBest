//
//  AddEditCourseViewЬщвуд.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation
import Combine
import SwiftUI

class AddEditCourseViewModel: ObservableObject {
    
    @Published var course: CourseModel? = nil
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var materialsText: String = ""
    @Published var materialsUrl: String = ""
    @Published var category: CategoryModel?
    @Published var categories: [CategoryModel] = []
    @Published var allSubcategories: [CategoryModel] = []
    @Published var subcategories: [CategoryModel] = []
    @Published var selectedCategoryId: UUID?
    @Published var selectedSubcategoryId: UUID?
    @Published var status: CourseStatusView = .initial
    @Published var user: UserModel?
    @Published var uploadingItems: Set<UUID> = []
    @Published var mediaItems: [CourseMediaItem] = []
    @Published var videoURL = ""
    @Published var isLoadingVideo = false
    @Published var videoTitle = ""
    @Published var videoThumbnailURL: URL?
    @Published var isValidURL = true

    var currentDragIndex: Int?
    
    private var videoMediaItemId: UUID?
    
    let maxMediaItemCount = 5
    private var cancellables = Set<AnyCancellable>()
    
    private let createCourseUseCase: CreateCourseUseCase
    private let editCourseUseCase: EditCourseUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let courseMediaUseCases: CourseMediaUseCases
    private let fetchVideoDetailsUseCase: FetchYouTubeVideoDetailsUseCase
    private let authStateManager: AuthStateManager
    
    enum CourseStatusView {
        case initial
        case loading
        case created
        case createdDraft
        case edited
        case error(message: String)
    }
    
    init(
        createCourseUseCase: CreateCourseUseCase,
        editCourseUseCase: EditCourseUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        courseMediaUseCases: CourseMediaUseCases,
        fetchVideoDetailsUseCase: FetchYouTubeVideoDetailsUseCase,
        authStateManager: AuthStateManager,
        course: CourseModel? = nil
    ) {
        self.createCourseUseCase = createCourseUseCase
        self.editCourseUseCase = editCourseUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.courseMediaUseCases = courseMediaUseCases
        self.fetchVideoDetailsUseCase = fetchVideoDetailsUseCase
        self.authStateManager = authStateManager
        
        setupBindings()
        
        Task {
            await fetchCategories()
            if let course {
                DispatchQueue.main.async {
                    self.initCourse(course: course)
                }
            }
        }
    }
    
    func initCourse(course: CourseModel) {
        self.course = course
        name = course.name
        description = course.description ?? ""
        price = "\(course.price)"
        materialsUrl = course.materialsUrl
        materialsText = course.materialsText ?? ""
        setSelectedCategoryIds(subcategoryId: course.categoryId)
        course.media.forEach { item in
            if item.name == nil {
                videoMediaItemId = item.id
                videoThumbnailURL = URL(string: item.url)
                videoURL = item.videoUrl ?? ""
            } else {
                mediaItems.append(item)
            }
        }
        mediaItems.sort(by: { $0.order < $1.order })
        
    }
    
    func setSelectedCategoryIds(subcategoryId: UUID) {
        guard let subcategory = allSubcategories.first(where: { $0.id == subcategoryId }) else { return }
        selectedSubcategoryId = subcategoryId
        selectedCategoryId = subcategory.parentCategoryId
        subcategories = allSubcategories.filter { $0.parentCategoryId == selectedCategoryId }
    }
    
    func fetchCategories() async {
        do {
            let allCategories = try await fetchCategoriesUseCase.execute()
            DispatchQueue.main.async {
                self.categories = allCategories.filter { $0.parentCategoryId == nil }
                self.allSubcategories = allCategories.filter { $0.parentCategoryId != nil }
            }
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func selectCategory(_ categoryId: UUID) {
        selectedCategoryId = categoryId
        selectedSubcategoryId = nil
        subcategories = allSubcategories.filter { $0.parentCategoryId == categoryId }
        //        Task {
        //            let allCategories = try await fetchCategoriesUseCase.execute()
        //            DispatchQueue.main.async {
        //                self.subcategories = allCategories.filter { $0.parentCategoryId == categoryId }
        //            }
        //        }
    }
    
    func selectSubcategory(_ subcategoryId: UUID) {
        selectedSubcategoryId = subcategoryId
    }
    
    func setupBindings() {
        authStateManager.$currentUser
            .compactMap { $0 }
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
        
        $videoURL
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] url in
                guard let self else { return }
                Task {
                    await self.fetchVideoDetails()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchVideoDetails() async {
        guard !videoURL.isEmpty, YouTubeURLParser.extractID(from: videoURL) != nil else {
            DispatchQueue.main.async {
                withAnimation {
                    self.videoTitle = ""
                    self.videoThumbnailURL = nil
                    if self.videoURL.isEmpty {
                        self.isValidURL = true
                    } else {
                        self.isValidURL = false
                    }
                }
            }
            return
        }
        do {
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoadingVideo = true
                    self.isValidURL = true
                }
            }
            let video = try await fetchVideoDetailsUseCase.execute(videoURL: videoURL)
            DispatchQueue.main.async {
                withAnimation {
                    self.videoTitle = video.title
                    self.videoThumbnailURL = video.thumbnailURL
                    self.isLoadingVideo = false
                }
            }
        } catch {
            print("error infetchVideoDetails: \(error)")
            DispatchQueue.main.async {
                withAnimation {
                    self.isValidURL = false
                    self.isLoadingVideo = false
                }
            }
        }
    }
    
    func createCourse() async {
        guard let user, let selectedSubcategoryId, !price.isEmpty else {
            print("Required fields are missing.")
            return
        }
        
        guard let priceValue = Double(price) else {
            print("Invalid price entered. Please enter a valid number.")
            return
        }
        do {
            DispatchQueue.main.async {
                self.status = .loading
            }
            let selectedCategory = categories.first { $0.id == selectedCategoryId }
            let selectedSubcategory = subcategories.first { $0.id == selectedSubcategoryId }
            
            let status: CourseStatus = authStateManager.canAccess(.publishCourse) ? .active : .moderation
            
            let currentDate = Date()
            let course = CourseModel(
                id: UUID(),
                categoryId: selectedSubcategoryId,
                userId: user.id,
                name: name,
                description: description,
                price: priceValue,
                materialsText: materialsText,
                materialsUrl: materialsUrl,
                status: status,
                createdAt: currentDate,
                updatedAt: currentDate,
                parentCategoryName: selectedCategory?.name ?? "",
                parentCategoryIconUrl: selectedCategory?.iconUrl ?? "",
                categoryName: selectedSubcategory?.name ?? "",
                categoryIconUrl: selectedSubcategory?.iconUrl ?? ""
            )
            try await createCourseUseCase.execute(course: course)
            
            let group = DispatchGroup()
            
            var mediaItems = self.mediaItems
            for index in mediaItems.indices {
                mediaItems[index].courseId = course.id
            }
            
            if let videoThumbnailURL {
                // Create a media item for the video
                let videoMedia = CourseMediaItem(
                    id: UUID(),
                    courseId: course.id,
                    name: nil,
                    url: videoThumbnailURL.absoluteString,
                    videoUrl: videoURL,
                    order: mediaItems.count,
                    createdAt: Date()
                )
                mediaItems.append(videoMedia)
                //mediaItems.insert(videoMedia, at: 0)  // Insert at the start for now
            }
            
//            if mediaItems.count > 1 && videoThumbnailURL != nil {
//                // Swap to place video at the second position
//                mediaItems.swapAt(0, 1)
//                mediaItems[0].order = 1
//                mediaItems[1].order = 2
//            }
            
            for item in mediaItems {
                group.enter()
                Task {
                    do {
                        try await courseMediaUseCases.createMediaItemUseCase.execute(mediaItem: item)
                    } catch {
                        print("Failed to upload media item: \(error)")
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.status = .created
                }
            }
        } catch {
            print("Error with creating new course: \(error)")
            DispatchQueue.main.async {
                self.status = .error(message: error.localizedDescription)
            }
        }
    }
    
    func saveToDrafts() async {
        guard let user, let selectedSubcategoryId, !price.isEmpty else {
            print("Required fields are missing.")
            return
        }
        
        guard let priceValue = Double(price) else {
            print("Invalid price entered. Please enter a valid number.")
            return
        }
        let isEditing = course != nil
        let courseId = course?.id ?? UUID()
        do {
            DispatchQueue.main.async {
                self.status = .loading
            }
            let currentDate = Date()
            let course = CourseModel(
                id: courseId,
                categoryId: selectedSubcategoryId,
                userId: user.id,
                name: name,
                description: description,
                price: priceValue,
                materialsText: materialsText,
                materialsUrl: materialsUrl,
                status: .uncompleted,
                createdAt: currentDate,
                updatedAt: currentDate
            )
            if isEditing {
                try await editCourseUseCase.execute(course: course)
            } else {
                try await createCourseUseCase.execute(course: course)
            }
            await updateMediaItems(courseId: course.id)
            DispatchQueue.main.async {
                self.status = .createdDraft
            }
        } catch {
            print("Error with creating draft course: \(error)")
            DispatchQueue.main.async {
                self.status = .error(message: error.localizedDescription)
            }
        }
    }
    
    func editCourse(model: CourseModel) async {
        guard let user, let selectedSubcategoryId, !price.isEmpty else {
            print("Required fields are missing.")
            return
        }
        
        guard let priceValue = Double(price) else {
            print("Invalid price entered. Please enter a valid number.")
            return
        }
        let selectedCategory = categories.first { $0.id == selectedCategoryId }
        let selectedSubcategory = subcategories.first { $0.id == selectedSubcategoryId }
        let status: CourseStatus = authStateManager.canAccess(.publishCourse) ? .active : .moderation
        
        // ❌ check any changes before sending to moderation!!!
        do {
            DispatchQueue.main.async {
                self.status = .loading
            }
            let course = CourseModel(
                id: model.id,
                categoryId: selectedSubcategoryId,
                userId: user.id,
                name: name,
                description: description,
                price: priceValue,
                materialsText: materialsText,
                materialsUrl: materialsUrl,
                status: status,
                createdAt: model.createdAt, 
                updatedAt: Date(),
                parentCategoryName: selectedCategory?.name ?? "",
                parentCategoryIconUrl: selectedCategory?.iconUrl ?? "",
                categoryName: selectedSubcategory?.name ?? "",
                categoryIconUrl: selectedSubcategory?.iconUrl ?? ""
            )
            try await editCourseUseCase.execute(course: course)
            await updateMediaItems(courseId: course.id)
            DispatchQueue.main.async {
                self.status = .edited
            }
        } catch {
            print("Error with creating new course: \(error)")
            DispatchQueue.main.async {
                self.status = .error(message: error.localizedDescription)
            }
        }
    }
    
    func fetchCurrentMediaItems(courseId: UUID) async -> [CourseMediaItem] {
        do {
            return try await courseMediaUseCases.fetchCourseMediaUseCase.execute(courseId: courseId)
        } catch {
            print("Failed to fetch current media items: \(error)")
            return []
        }
    }
    
    func determineMediaChanges(currentMedia: [CourseMediaItem], newMedia: [CourseMediaItem]) -> (toAdd: [CourseMediaItem], toRemove: [CourseMediaItem], toUpdate: [CourseMediaItem]) {
        let currentSet = Set(currentMedia.map { $0.id })
        let newSet = Set(newMedia.map { $0.id })
        
        let toAdd = newMedia.filter { !currentSet.contains($0.id) }
        let toRemove = currentMedia.filter { !newSet.contains($0.id) }
        let toUpdate = newMedia.filter { newItem in
            guard let currentItem = currentMedia.first(where: { $0.id == newItem.id }) else {
                return false
            }
            return newItem.order != currentItem.order || newItem.url != currentItem.url || newItem.name != currentItem.name
        }
        
        return (toAdd, toRemove, toUpdate)
    }
    
    func updateMediaItems(courseId: UUID) async {
        let currentMedia = await fetchCurrentMediaItems(courseId: courseId)
        if let item = currentMedia.first(where: { $0.videoUrl == videoURL }) {
            DispatchQueue.main.async {
                self.mediaItems.append(item)
            }
        } else if let imageUrl = videoThumbnailURL?.absoluteString {
            let videoMedia = CourseMediaItem(
                id: videoMediaItemId ?? UUID(),
                courseId: courseId,
                name: nil,
                url: imageUrl,
                videoUrl: videoURL,
                order: mediaItems.count,
                createdAt: Date()
            )
            DispatchQueue.main.async {
                self.mediaItems.append(videoMedia)
            }
        }
        
        let changes = determineMediaChanges(currentMedia: currentMedia, newMedia: mediaItems)
        
        //         Add new media items
        for item in changes.toAdd {
            Task {
                do {
                    print("adding item \(item)")
                    try await courseMediaUseCases.createMediaItemUseCase.execute(mediaItem: item)
                } catch {
                    print("Failed to add media item: \(error)")
                }
            }
        }
        
        // Remove deleted media items
        for item in changes.toRemove {
            Task {
                do {
                    print("removing item \(item)")
                    try await courseMediaUseCases.deleteMediaItemUseCase.execute(mediaItem: item)
                } catch {
                    print("Failed to remove media item: \(error)")
                }
            }
        }
        
        // Update changed media items (primarily order)
        for item in changes.toUpdate {
            Task {
                do {
                    print("updating item \(item)")
                    try await courseMediaUseCases.updateMediaItemUseCase.execute(mediaItem: item)
                } catch {
                    print("Failed to update media item: \(error)")
                }
            }
        }
    }
    
    func uploadMediaItem(imageData: Data) async {
        guard mediaItems.count < maxMediaItemCount else {
            print("media limit exceeds")
            return
        }
        
        print("starting upload, mediaItems count: \(mediaItems.count)")
        let fileName = "uploaded_image_\(UUID().uuidString).jpg"
        let mediaItem = CourseMediaItem(id: UUID(), courseId: UUID(), name: fileName, url: "", videoUrl: nil, order: mediaItems.count, createdAt: Date())
        DispatchQueue.main.async {
            self.mediaItems.append(mediaItem)
            self.uploadingItems.insert(mediaItem.id)  // Mark as uploading
        }
        
        do {
            if let url = try await courseMediaUseCases.uploadMediaItemUseCase.execute(
                fileData: imageData,
                fileName: fileName,
                contentType: "image/jpeg"
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let index = self.mediaItems.firstIndex(where: { $0.id == mediaItem.id }) {
                        self.mediaItems[index].url = url.absoluteString
                    }
                    self.uploadingItems.remove(mediaItem.id)
                }
            }
        } catch {
            print("Error in uploadMediaItem: \(error)")
            DispatchQueue.main.async {
                self.uploadingItems.remove(mediaItem.id)
            }
        }
    }
    
    func moveMediaItems(from source: IndexSet, to destination: Int) {
        mediaItems.move(fromOffsets: source, toOffset: destination)
        reorderMediaItems()  // update the order after moving
    }
    
    // Function to reorder mediaItems based on their current indices
    func reorderMediaItems() {
        for index in mediaItems.indices {
            mediaItems[index].order = index
        }
    }
    
    func removeMediaItem(at offsets: IndexSet) {
        guard let index = offsets.first else { return }  // only one item can be deleted at a time
        let itemToDelete = mediaItems[index]
        
        Task {
            do {
                try await deleteMediaItem(item: itemToDelete)
                DispatchQueue.main.async {
                    self.mediaItems.remove(atOffsets: offsets)
                    self.reorderMediaItems()
                }
            } catch {
                print("Error in deleting media item: \(error)")
            }
        }
    }
    
    func deleteMediaItem(item: CourseMediaItem) async throws {
        try await courseMediaUseCases.deleteMediaItemUseCase.execute(mediaItem: item)
    }
}
