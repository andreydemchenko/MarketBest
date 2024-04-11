//
//  ProfileViewModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    @Published var isLoading = false
    
    private let signOutUseCase: SignOutUseCase
    
    init(signOutUseCase: SignOutUseCase) {
        self.signOutUseCase = signOutUseCase
    }
    
    @MainActor
    func signOut(onSignedOut: () -> Void) async {
        do {
            isLoading = true
            try await signOutUseCase.execute()
            onSignedOut()
        } catch {
            print("sign out error: \(error)")
        }
        isLoading = false
    }
}
