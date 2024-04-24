//
//  FavoritesManager.swift
//  MarketBest
//
//  Created by Macbook Pro on 24.04.2024.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    
    @Published var favoriteCourses: Set<UUID> = []
    @Published var userId: UUID?
    
    private let addToFavouritesUseCase: AddToFavouritesUseCase
    private let removeFromFavouritesUseCase: RemoveFromFavouritesUseCase
    private let fetchFavouritesUseCase: FetchFavouritesUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        addToFavouritesUseCase: AddToFavouritesUseCase,
        removeFromFavouritesUseCase: RemoveFromFavouritesUseCase,
        fetchFavouritesUseCase: FetchFavouritesUseCase,
        authStateManager: AuthStateManager
    ) {
        self.addToFavouritesUseCase = addToFavouritesUseCase
        self.removeFromFavouritesUseCase = removeFromFavouritesUseCase
        self.fetchFavouritesUseCase = fetchFavouritesUseCase
        
        authStateManager.$currentUser
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] user in
                guard let self = self else { return }
                
                if let user {
                    self.userId = user.id
                    self.fetchFavorites()
                }
            }
            .store(in: &cancellables)
    }
    
    
    func fetchFavorites() {
        guard let userId else { return }
        Task {
            do {
                let favorites = try await fetchFavouritesUseCase.execute(userId: userId)
                DispatchQueue.main.async {
                    self.favoriteCourses = Set(favorites.map { $0.courseId })
                }
            } catch {
                print("Error fetching favorites: \(error)")
            }
        }
    }
    
    func toggleFavorite(courseId: UUID, onAdded: @escaping () -> Void, onRemoved: @escaping () -> Void) {
        guard let userId else { return }
        if favoriteCourses.contains(courseId) {
            Task {
                do {
                    try await removeFromFavouritesUseCase.execute(userId: userId, courseId: courseId)
                    DispatchQueue.main.async {
                        self.favoriteCourses.remove(courseId)
                        onAdded()
                    }
                } catch {
                    print("Error removing from favorites: \(error)")
                }
            }
        } else {
            Task {
                do {
                    try await addToFavouritesUseCase.execute(userId: userId, courseId: courseId)
                    DispatchQueue.main.async {
                        self.favoriteCourses.insert(courseId)
                        onRemoved()
                    }
                } catch {
                    print("Error adding to favorites: \(error)")
                }
            }
        }
    }
    
}
