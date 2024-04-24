//
//  ProfileView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI
import FancyScrollView

struct ProfileView: View {
    @EnvironmentObject var stateManager: AuthStateManager
    @EnvironmentObject var viewModel: ProfileViewModel
    
    @State private var isAnimatingImage: Bool = false
    @State private var isAnimating: Bool = false
    
    private var headerHeight: CGFloat = 220
    
    var body: some View {
        if let user = stateManager.currentUser {
            FancyScrollView(
                title: user.name,
                headerHeight: headerHeight,
                scrollUpHeaderBehavior: .parallax,
                scrollDownHeaderBehavior: .offset,
                header: {
                    headerView
                }
            ) {
                VStack {
                    Text(user.email)
                        .font(.mulishRegularFont(size: 16))
                        .foregroundStyle(Color.primaryColor)
                    Spacer().frame(height: 40)
                    if viewModel.authStateManager.canAccess(.moderation) {
                        ProfileItemView(title: "Модерация", imageName: "person.badge.clock", count: viewModel.moderationCourses.count, onTap: {
                            
                        }).task {
                            await viewModel.fetchModerationCourses()
                        }
                    }
                    ProfileItemView(title: "Заказы", imageName: "cart", count: 2, onTap: {
                        
                    })
                    ProfileItemView(title: "Оплата", imageName: "creditcard", count: 0, onTap: {
                        
                    })
                    Spacer().frame(height: 60)
                    Button {
                        Task {
                            await viewModel.signOut(onSignedOut: {
                                DispatchQueue.main.async {
                                    self.stateManager.currentUser = nil
                                }
                            })
                        }
                    } label: {
                        Text("Выйти из аккаунта")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.redColor)
                            .foregroundStyle(Color.tertiaryColor)
                            .font(.mulishBoldFont(size: 16))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                }
                .padding()
                .background(Color.darkRedColor)
                .task {
                    await viewModel.loadImage(user: user)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.darkRedColor)
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
        } else {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.black)
        }
           
    }
    
    var headerView: some View {
        ZStack(alignment: .top) {
            VStack {
                ZStack {
                    Rectangle()
                        .foregroundStyle(Color.primaryColor)
                        .edgesIgnoringSafeArea(.top)
                        .shadow(color: Color.primaryColor, radius: 6)
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            Image("editIcon")
                                .resizable()
                                .frame(maxWidth: 32, maxHeight: 32)
                        }
                            
                    }
                    .padding(20)
                }
                Rectangle()
                    .foregroundStyle(Color.darkRedColor)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: headerHeight/3)
            }
            
            VStack {
                Spacer().frame(height: 60)
                HStack {
                    Spacer()
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.primaryColor, lineWidth: 4))
                            .shadow(radius: 10)
                    } else if viewModel.isLoadingImage {
                        Group {
                            BarsLoader(isAnimating: $isAnimatingImage, color: Color.tertiaryColor)
                                .onAppear {
                                    isAnimatingImage = true
                                }
                                .onDisappear {
                                    isAnimatingImage = false
                                }
                        }
                        .padding(40)
                        .background(Color.primaryColor)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.primaryColor, lineWidth: 4))
                        .shadow(radius: 10)
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(40)
                            .background(Color.primaryColor)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.primaryColor, lineWidth: 4))
                            .shadow(radius: 10)
                    }
                    Spacer()
                }
                Spacer().frame(height: 40)
            }

        }
    }
}

struct ProfileItemView: View {
    
    let title: String
    let imageName: String
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(systemName: imageName)
                    .foregroundStyle(Color.primaryColor)
                HStack {
                    Text(title)
                        .font(.mulishMediumFont(size: 16))
                        .foregroundStyle(Color.primaryColor)
                    if count > 0 {
                        Text(count < 100 ? "\(count)" : "99+")
                            .font(.mulishMediumFont(size: 16))
                            .foregroundStyle(Color.darkRed)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Color.redColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 8)
                Spacer()
                Image(systemName: "arrow.forward")
                    .foregroundStyle(Color.primaryColor)
            }
            .frame(height: 50)
        }
    }
}

//#Preview {
//    ProfileView()
//        .environmentObject(DependencyContainer().authStateManager)
//        .environmentObject(ProfileViewModel(signOutUseCase: DependencyContainer().signOutUseCase))
//}
