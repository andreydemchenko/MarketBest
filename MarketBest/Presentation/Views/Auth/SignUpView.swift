//
//  SignUpView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var stateManager: AuthStateManager
    @State private var isShowEmailError = false
    @State private var isShowPasswordError = false

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Создать аккаунт")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                TextField("Имя", text: $viewModel.name)
                    .textContentType(.emailAddress)
                    .foregroundStyle(.black)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                VStack(alignment: .leading) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .foregroundStyle(.black)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    if isShowEmailError && !viewModel.email.isValidEmail() {
                        Text(viewModel.email.isEmpty ? "Введите email" : "Некоррекный email")
                            .padding(.leading)
                            .foregroundStyle(.white)
                            .font(.footnote)
                    }
                }
                VStack(alignment: .leading) {
                    SecureField("Пароль", text: $viewModel.password)
                        .textContentType(.password)
                        .foregroundStyle(.black)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    if isShowPasswordError && !viewModel.password.isValidPassword() {
                        Text("Пароль должен содержать хотя бы 6 символов")
                            .padding(.leading)
                            .foregroundStyle(.white)
                            .font(.footnote)
                    }
                }
            }
            .padding(.bottom)
            Button {
                if !viewModel.email.isValidEmail() {
                    isShowEmailError = true
                }
                if !viewModel.password.isValidPassword() {
                    isShowPasswordError = true
                }
                if viewModel.email.isValidEmail(), viewModel.password.isValidPassword() {
                    Task {
                        await viewModel.signUp(onSignUp: {
                            Task {
                                await stateManager.fetchCurrentUser()
                            }
                        })
                    }
                }
            } label: {
                Text("Зарегистрироваться")
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
                Text("Уже есть аккаунт?")
                    .foregroundStyle(.black)
                Button("Войти") {
                    stateManager.showSignIn()
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
    SignUpView()
        .environmentObject(AuthViewModel(signUpUseCase: DependencyContainer().signUpUseCase, signInUseCase: DependencyContainer().signInUseCase, createUserUseCase: DependencyContainer().createUserUseCase))
        .environmentObject(DependencyContainer().authStateManager)
}
