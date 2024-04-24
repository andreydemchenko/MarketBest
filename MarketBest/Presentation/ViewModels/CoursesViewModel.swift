//
//  CoursesViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

class CoursesViewModel: ObservableObject {
    
    private let fetchCoursesUseCase: FetchCoursesUseCase
    private let addToFavouritesUseCase: AddToFavouritesUseCase
    private let removeFromFavouritesUseCase: RemoveFromFavouritesUseCase
    private let fetchFavouritesUseCase: FetchFavouritesUseCase
    
    init(
        fetchCoursesUseCase: FetchCoursesUseCase,
        addToFavouritesUseCase: AddToFavouritesUseCase,
        removeFromFavouritesUseCase: RemoveFromFavouritesUseCase,
        fetchFavouritesUseCase: FetchFavouritesUseCase
    ) {
        self.fetchCoursesUseCase = fetchCoursesUseCase
        self.addToFavouritesUseCase = addToFavouritesUseCase
        self.removeFromFavouritesUseCase = removeFromFavouritesUseCase
        self.fetchFavouritesUseCase = fetchFavouritesUseCase
    }
    
}
