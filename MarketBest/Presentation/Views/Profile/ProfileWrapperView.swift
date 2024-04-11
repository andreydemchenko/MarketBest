//
//  ProfileWrapperView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct ProfileWrapperView: View {
    
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var authStateManager: AuthStateManager
    
    var body: some View {
        if authStateManager.isLoadingUser {
            SplashView()
        } else if authStateManager.currentUser != nil {
            ProfileView()
                .environmentObject(authStateManager)
                .environmentObject(ProfileViewModel(signOutUseCase: container.signOutUseCase))
        } else {
            switch authStateManager.authFlow {
            case .signIn:
                SignInView()
                    .environmentObject(authStateManager)
                    .environmentObject(AuthViewModel(signUpUseCase: container.signUpUseCase, signInUseCase: container.signInUseCase, createUserUseCase: container.createUserUseCase))
            case .signUp:
                SignUpView()
                    .environmentObject(authStateManager)
                    .environmentObject(AuthViewModel(signUpUseCase: container.signUpUseCase, signInUseCase: container.signInUseCase, createUserUseCase: container.createUserUseCase))
            }
        }
    }
}

#Preview {
    ProfileWrapperView()
}
