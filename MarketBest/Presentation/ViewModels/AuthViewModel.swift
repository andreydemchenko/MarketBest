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
    
    func signUp(onSignUp: () -> Void) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            if let id = try await signUpUseCase.execute(email: email, password: password), let uuid = UUID(uuidString: id) {
                let user = UserModel(id: uuid, name: name, email: email, imageUrl: nil)
                try await createUserUseCase.execute(user: user)
                try await Task.sleep(seconds: 2)
                onSignUp()
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Coudln't authenticate a user"
                }
            }
        } catch let error {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            print("error in sign up: \(errorMessage)")
        }
    }
    
    func signIn(onSignIn: () -> Void) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        //defer { isLoading = false }
        do {
            let id = try await signInUseCase.execute(email: email, password: password)
            if id == nil {
                DispatchQueue.main.async {
                    self.errorMessage = "Coudln't authenticate a user"
                    self.isLoading = false
                }
                print("error in sign in")
                return
            }
            try await Task.sleep(seconds: 2)
            onSignIn()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch let error {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("error in sign in: \(errorMessage)")
        }
    }
    
}
