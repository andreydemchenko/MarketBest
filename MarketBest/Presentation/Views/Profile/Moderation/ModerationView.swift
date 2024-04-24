//
//  ModerationView.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import SwiftUI
import NavigationBackport

struct ModerationView: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    router.path.removeLast()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 14, height: 20)
                        .foregroundStyle(Color.primaryColor)
                }

                Text("Модерация")
                    .padding()
                    .foregroundStyle(Color.primaryColor)
                    .font(.mulishBoldFont(size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .frame(height: 32)
            .padding(.horizontal)
            
            if viewModel.courses.isEmpty && !viewModel.isLoading {
                Spacer()
                Text("Нет курсов для проверки")
                    .padding()
                    .foregroundStyle(Color.primaryColor)
                    .font(.mulishRegularFont(size: 18))
                Spacer()
            } else {
                ScrollView {
                    Spacer()
                        .frame(height: 30)
                    ForEach(viewModel.courses, id: \.id) { course in
                        ModerationCourseItemView(item: course, onOpenDetails: {
                            router.path.append(.moderationCourseDetails(course: course))
                        })
                    }
                }
                .background(Color.backgroundColor)
                .ignoresSafeArea(edges: .bottom)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchModerationCourses()
            }
        }
    }
}

#Preview {
    ModerationView()
        .environmentObject(ProfileViewModel(signOutUseCase: DependencyContainer().signOutUseCase, fetchCoursesByStatusUseCase: DependencyContainer().fetchCoursesByStatusUseCase, fetchCategoriesUseCase: DependencyContainer().fetchCategoriesUseCase, fetchCourseMediaUseCase: DependencyContainer().fetchCourseMediaUseCase, authStateManager: DependencyContainer().authStateManager))
}
