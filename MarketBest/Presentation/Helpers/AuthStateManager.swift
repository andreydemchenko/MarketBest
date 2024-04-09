//
//  AuthStateManager.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

class AuthStateManager: ObservableObject {
    @Published var currentUser: UserModel?
    private let currentUserUseCase: FetchCurrentUserUseCase
    
    init(currentUserUseCase: FetchCurrentUserUseCase) {
        self.currentUserUseCase = currentUserUseCase
        Task { await fetchCurrentUser() }
    }
    
    func fetchCurrentUser() async {
        do {
            if let user = try await currentUserUseCase.execute() {
                DispatchQueue.main.async { self.currentUser = user }
            }
        } catch {
            print("Failed to fetch current user: \(error)")
        }
    }
    
    var userRole: UserRole {
        currentUser?.role ?? .guest
    }
    
    func canAccess(_ feature: AppFeature) -> Bool {
        switch userRole {
        case .admin:
            return true
        case .customer:
            return feature == .viewCourses || feature == .purchaseCourse
        case .guest:
            return feature == .viewCourses
        }
    }
}

enum AppFeature {
    case viewCourses, purchaseCourse, createCourse, editCourse
}
