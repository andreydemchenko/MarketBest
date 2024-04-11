//
//  SignInView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var stateManager: AuthStateManager
    @State private var isShowError = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Войти в аккаунт")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .foregroundStyle(.black)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                VStack(alignment: .leading) {
                    SecureField("Пароль", text: $viewModel.password)
                        .textContentType(.password)
                        .foregroundStyle(.black)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    if isShowError {
                        Text("Неверный email или пароль")
                            .padding(.leading)
                            .foregroundStyle(.white)
                            .font(.footnote)
                    }
                }
            }
            .padding(.bottom)
            Button {
                if viewModel.email.isValidEmail(), viewModel.password.isValidPassword() {
                    Task {
                        await viewModel.signIn(onSignIn: {
                            Task {
                                await stateManager.fetchCurrentUser()
                            }
                        })
                    }
                }
            } label: {
                Text("Войти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundStyle(.white)
                    .font(.headline)
                    .cornerRadius(16)
                    .shadow(radius: 4)
            }
            
            
            Spacer()
            
            HStack {
                Text("Еще нет аккаунта?")
                    .foregroundStyle(.black)
                Button("Зарегистрироваться") {
                    stateManager.showSignUp()
                }
                .foregroundStyle(.black)
                //.underline(color: .black)
            }
            .padding(4)
            Spacer()
                .frame(height: 60)
        }
        .padding()
        .background(
          LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel(signUpUseCase: DependencyContainer().signUpUseCase, signInUseCase: DependencyContainer().signInUseCase, createUserUseCase: DependencyContainer().createUserUseCase))
        .environmentObject(DependencyContainer().authStateManager)
}
