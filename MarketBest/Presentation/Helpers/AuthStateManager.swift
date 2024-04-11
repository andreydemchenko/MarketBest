//
//  AuthStateManager.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

class AuthStateManager: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var authFlow: AuthFlow = .signUp
    @Published var isLoadingUser: Bool = false
    
    enum AuthFlow {
        case signIn, signUp
    }
    
    private let currentUserUseCase: FetchCurrentUserUseCase
    
    init(currentUserUseCase: FetchCurrentUserUseCase) {
        self.currentUserUseCase = currentUserUseCase
        Task { await fetchCurrentUser() }
    }
    
    func fetchCurrentUser() async {
        do {
            DispatchQueue.main.async {
                self.isLoadingUser = true
            }
            if let user = try await currentUserUseCase.execute() {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoadingUser = false
                }
            } else {
                DispatchQueue.main.async {
                    self.currentUser = nil
                    self.isLoadingUser = false
                }
            }
        } catch {
            print("Failed to fetch current user: \(error)")
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isLoadingUser = false
            }
        }
    }
    
    var userRole: UserRole {
        currentUser?.role ?? .guest
    }
    
    func showSignIn() {
        authFlow = .signIn
    }
    
    func showSignUp() {
        authFlow = .signUp
    }
    
    func canAccess(_ feature: AppFeature) -> Bool {
        switch userRole {
        case .admin:
            return true
        case .customer:
            return feature == .viewCourses || feature == .purchaseCourse || feature == .createCourse || feature == .editCourse
        case .guest:
            return feature == .viewCourses
        }
    }
}

enum AppFeature {
    case viewCourses, purchaseCourse, createCourse, editCourse, moderation
}
