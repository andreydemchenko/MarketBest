//
//  ProfileView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var stateManager: AuthStateManager
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            if let user = stateManager.currentUser {
                VStack(alignment: .leading, spacing: 20) {
                    Text(user.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    Text(user.email)
                        .font(.headline)
                        .foregroundStyle(.black)
                }
                Spacer()
                Button {
                    Task {
                        await viewModel.signOut(onSignedOut: {
                            stateManager.currentUser = nil
                        })
                    }
                } label: {
                    Text("Выйти из аккаунта")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                }
                Spacer()
                    .frame(height: 60)
            } else {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }
        }
        .padding()
        .background(.white)
    }
}

#Preview {
    ProfileView()
        .environmentObject(DependencyContainer().authStateManager)
        .environmentObject(ProfileViewModel(signOutUseCase: DependencyContainer().signOutUseCase))
}
