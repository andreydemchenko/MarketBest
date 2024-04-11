//
//  MyCoursesViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation

class MyCoursesViewModel: ObservableObject {
    
    @Published var courses: [CourseModel] = []
    @Published var isLoading = false
    
    private var fetchMyCoursesUseCase: FetchMyCoursesUseCase
    private var userId: UUID
    
    init(fetchMyCoursesUseCase: FetchMyCoursesUseCase, userId: UUID) {
        self.fetchMyCoursesUseCase = fetchMyCoursesUseCase
        self.userId = userId
        Task {
            await fetchMyCourses()
        }
    }
    
    func fetchMyCourses() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            let response = try await fetchMyCoursesUseCase.execute(userId: UUID(uuidString: "975875bd-8446-45f4-b57f-db8835fde0ec")!)
            DispatchQueue.main.async {
                self.courses = response
                self.isLoading = false
            }
        } catch {
            print("error in fetchMyCourses: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
