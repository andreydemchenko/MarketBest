//
//  AddEditCourseView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI

struct AddEditCourseView: View {
    
    @EnvironmentObject var viewModel: AddEditCourseViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Создать курс")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryColor)
                    Spacer()
                    Button {
                        Task {
                            await viewModel.saveToDrafts()
                            router.path.pop()
                        }
                    } label: {
                        Text("Сохранить")
                            .foregroundStyle(Color.primaryColor)
                    }
                }
                Spacer()
                    .frame(height: 20)
                TextField("Название", text: $viewModel.name)
                    .textContentType(.emailAddress)
                    .foregroundStyle(Color.tertiaryColor)
                    .padding()
                    .background(Color.primaryColor.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    TextField("Описание", text: $viewModel.description)
                        .textContentType(.emailAddress)
                        .foregroundStyle(Color.tertiaryColor)
                        .padding()
                        .background(Color.primaryColor.opacity(0.9))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                TextField("Цена", value: $viewModel.price, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .foregroundStyle(Color.tertiaryColor)
                    .padding()
                    .background(Color.primaryColor.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                TextField("Материалы", text: $viewModel.materialsText)
                    .textContentType(.emailAddress)
                    .foregroundStyle(Color.tertiaryColor)
                    .padding()
                    .background(Color.primaryColor.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                TextField("Ссылка", text: $viewModel.materialsUrl)
                    .textContentType(.emailAddress)
                    .foregroundStyle(Color.tertiaryColor)
                    .padding()
                    .background(Color.primaryColor.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                }
            .padding(.bottom)
            Spacer()
                .frame(height: 20)
            Button {
                Task {
                    await viewModel.createCourse()
                    router.path.pop()
                }
            } label: {
                Text("Опубликовать")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.darkRedColor)
                    .foregroundStyle(.white)
                    .font(.headline)
                    .cornerRadius(16)
                    .shadow(radius: 4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.tertiaryColor)
    }
}

#Preview {
    AddEditCourseView()
        .environmentObject(AddEditCourseViewModel(createCourseUseCase: DependencyContainer().createCourseUseCase, editCourseUseCase: DependencyContainer().editCourseUseCase, userId: DependencyContainer().authStateManager.currentUser?.id ?? UUID()))
}
