//
//  AuthViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

class AuthViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    
    private let signUpUseCase: SignUpUseCase
    private let signInUseCase: SignInUseCase
    private let createUserUseCase: CreateUserUseCase
    
    init(signUpUseCase: SignUpUseCase, signInUseCase: SignInUseCase, createUserUseCase: CreateUserUseCase) {
        self.signUpUseCase = signUpUseCase
        self.signInUseCase = signInUseCase
        self.createUserUseCase = createUserUseCase
    }
    
    @MainActor
    func signUp(onSignUp: () -> Void) async {
        do {
            isLoading = true
            if let id = try await signUpUseCase.execute(email: email, password: password), let uuid = UUID(uuidString: id) {
                let user = UserModel(id: uuid, name: name, email: email, imageUrl: nil)
                try await createUserUseCase.execute(user: user)
                onSignUp()
            } else {
                errorMessage = "Coudln't authenticate a user"
            }
        } catch let error {
            errorMessage = error.localizedDescription
            print("error in sign up: \(errorMessage)")
        }
        isLoading = false
    }
    
    @MainActor
    func signIn(onSignIn: () -> Void) async {
        do {
            isLoading = true
            let id = try await signInUseCase.execute(email: email, password: password)
            if id == nil {
                errorMessage = "Coudln't authenticate a user"
                return
            }
            onSignIn()
        } catch let error {
            errorMessage = error.localizedDescription
            print("error in sign in: \(errorMessage)")
        }
        isLoading = false
    }
    
}
