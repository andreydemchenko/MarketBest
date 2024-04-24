//
//  SignInView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct SignInView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var stateManager: AuthStateManager
    @State private var isShowError = false
    @State private var isShowEmailError = false
    @State private var isShowPasswordError = false
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @State private var isAnimating: Bool = false
    
    var isFormValid: Bool {
        return viewModel.email.isValidEmail() && viewModel.password.isValidPassword()
    }

    var buttonBackgroundColor: Color {
        isFormValid ? Color.accentColor : Color.secondaryColor
    }
    
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Войти в аккаунт")
                    .font(.mulishExtraBoldFont(size: 32))
                    .foregroundStyle(Color.primaryColor)
                VStack(alignment: .leading, spacing: 4) {
                    CustomTextField(
                        placeholder: "Email",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        returnKeyType: .next,
                        onReturn: {
                            DispatchQueue.main.async {
                                emailFocused = false
                                passwordFocused = true
                            }
                        }
                    )
                        .focused($emailFocused)
                    if isShowEmailError && !viewModel.email.isValidEmail() {
                        Text(viewModel.email.isEmpty ? "Введите email" : "Некоррекный email")
                            .padding(.leading)
                            .foregroundStyle(Color.accentColor)
                            .font(.mulishRegularFont(size: 12))
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    CustomTextField(
                        placeholder: "Пароль",
                        text: $viewModel.password,
                        isSecure: true,
                        returnKeyType: .done,
                        onReturn: {
                            DispatchQueue.main.async {
                                passwordFocused = false
                            }
                        }
                    )
                        .focused($passwordFocused)
                    if isShowPasswordError && !viewModel.password.isValidPassword() {
                        Text("Пароль должен содержать хотя бы 6 символов")
                            .padding(.leading)
                            .foregroundStyle(Color.accentColor)
                            .font(.mulishRegularFont(size: 12))
                    }
                }
            }
            .padding(.bottom)
            Button {
                validateAndSignIn()
            } label: {
                Text("Войти")
                    .frame(maxWidth: .infinity)
                    .font(.mulishBoldFont(size: 16))
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundStyle(isFormValid ? Color.backgroundColor : Color.tertiaryColor)
                    .font(.headline)
                    .cornerRadius(16)
                    .shadow(color: isFormValid ? Color.accentColor : Color.clear, radius: 4)
            }
            
            Spacer()
            signUpOption
            Spacer()
                .frame(height: 60)
        }
        .onAppear {
            DispatchQueue.main.async {
                emailFocused = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            resignFocus()
        }
        .padding()
        .background(
            Color.backgroundColor
            .edgesIgnoringSafeArea(.all))
        .overlay {
                ZStack {
                    if viewModel.isLoading {
                        Color.primaryColor.opacity(0.3).edgesIgnoringSafeArea(.all)
                        BarsLoader(isAnimating: $isAnimating, color: Color.tertiaryColor)
                            .frame(width: 50, height: 50)
                            .onAppear {
                                isAnimating = true
                            }
                            .onDisappear {
                                isAnimating = false
                            }
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
        }
    }
    
    private func validateAndSignIn() {
        isShowEmailError = !viewModel.email.isValidEmail()
        isShowPasswordError = !viewModel.password.isValidPassword()
        
        if !isShowEmailError, !isShowPasswordError {
            resignFocus()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await viewModel.signIn(onSignIn: {
                        Task {
                            await stateManager.fetchCurrentUser()
                        }
                    })
                }
            }
        }
    }
    
    var signUpOption: some View {
        HStack {
            Text("Еще нет аккаунта?")
                .foregroundStyle(Color.primaryColor)
                .font(.mulishMediumFont(size: 16))
            Button {
                router.showSignUp = true
            } label: {
                Text("Зарегистрироваться")
                    .font(.mulishMediumFont(size: 16))
                    .underline()
            }
        }
        .foregroundStyle(Color.primaryColor)
        .padding(4)
    }
    
    private func resignFocus() {
        emailFocused = false
        passwordFocused = false
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel(signUpUseCase: DependencyContainer().signUpUseCase, signInUseCase: DependencyContainer().signInUseCase, createUserUseCase: DependencyContainer().createUserUseCase))
        .environmentObject(DependencyContainer().authStateManager)
}
