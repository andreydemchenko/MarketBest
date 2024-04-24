//
//  SignUpView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var stateManager: AuthStateManager
    @State private var isShowNameError = false
    @State private var isShowEmailError = false
    @State private var isShowPasswordError = false
    @FocusState private var nameFocused: Bool
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @State private var isAnimating: Bool = false
    
    var isFormValid: Bool {
        return viewModel.email.isValidEmail() && viewModel.password.isValidPassword() && viewModel.name.isValidName()
    }

    var buttonBackgroundColor: Color {
        isFormValid ? Color.accentColor : Color.secondaryColor
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Создать аккаунт")
                    .font(.mulishExtraBoldFont(size: 32))
                    .foregroundStyle(Color.primaryColor)
                
                Spacer().frame(height: 18)
                
                VStack(alignment: .leading, spacing: 4) {
                    CustomTextField(
                        placeholder: "Имя",
                        text: $viewModel.name,
                        returnKeyType: .next,
                        onReturn: {
                            DispatchQueue.main.async {
                                nameFocused = false
                                emailFocused = true
                            }
                        }
                    )
                    .focused($nameFocused)
                    if isShowNameError && !viewModel.name.isValidName() {
                        Text(viewModel.name.isEmpty ? "Введите имя" : "Имя должно содержать хотя бы 2 буквы")
                            .padding(.leading)
                            .foregroundStyle(Color.accentColor)
                            .font(.mulishRegularFont(size: 12))
                    }
                }
                
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
                validateAndSignUp()
            } label: {
                Text("Зарегистрироваться")
                    .frame(maxWidth: .infinity)
                    .font(.mulishBoldFont(size: 16))
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundStyle(isFormValid ? Color.backgroundColor : Color.primaryColor)
                    .font(.headline)
                    .cornerRadius(16)
                    .shadow(color: isFormValid ? Color.accentColor : Color.clear, radius: 4)
            }
            .shadow(radius: 4)
            
            Spacer()
            signInOption
            Spacer().frame(height: 60)
        }
        .onAppear {
            DispatchQueue.main.async {
                nameFocused = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .disabled(viewModel.isLoading)
        .onTapGesture {
            resignFocus()
        }
        .padding()
        .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
        .overlay {
            if viewModel.isLoading {
                ZStack {
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
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
            }
        }
    }
    
    var signInOption: some View {
        HStack {
            Text("Уже есть аккаунт?")
                .foregroundStyle(Color.primaryColor)
                .font(.mulishMediumFont(size: 16))
            Button {
                router.showSignUp = false
            } label: {
                Text("Войти")
                    .font(.mulishMediumFont(size: 16))
                    .underline()
            }
        }
        .foregroundStyle(Color.primaryColor)
        .padding(4)
    }
    
    private func validateAndSignUp() {
        isShowEmailError = !viewModel.email.isValidEmail()
        isShowPasswordError = !viewModel.password.isValidPassword()
        isShowNameError = !viewModel.name.isValidName()
        
        if !isShowEmailError, !isShowPasswordError, !isShowNameError {
            resignFocus()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await viewModel.signUp(onSignUp: {
                        Task {
                            await stateManager.fetchCurrentUser()
                        }
                    })
                }
            }
        }
    }
    
    private func resignFocus() {
        nameFocused = false
        emailFocused = false
        passwordFocused = false
    }
}


#Preview {
    SignUpView()
        .environmentObject(AuthViewModel(signUpUseCase: DependencyContainer().signUpUseCase, signInUseCase: DependencyContainer().signInUseCase, createUserUseCase: DependencyContainer().createUserUseCase))
        .environmentObject(DependencyContainer().authStateManager)
}
