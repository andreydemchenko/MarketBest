//
//  CourseDetailsViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

class CourseDetailsViewModel: ObservableObject {
    
    @Published var course: CourseModel
    @Published var isLoading = false
    
    private let favoritesManager: FavoritesManager
    
    init(
        course: CourseModel,
        favoritesManager: FavoritesManager
    ) {
        self.course = course
        self.favoritesManager = favoritesManager
    }
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(
            courseId: course.id,
            onAdded: {
                DispatchQueue.main.async {
                    self.course.isMyFavourite = false
                }
            },
            onRemoved: {
                DispatchQueue.main.async {
                    self.course.isMyFavourite = true
                }
            }
        )
    }
    
    func isFavouriteCourse() -> Bool {
        return favoritesManager.favoriteCourses.contains(course.id)
    }

}
