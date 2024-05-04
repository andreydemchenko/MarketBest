//
//  LibraryView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI
import Kingfisher
import FancyScrollView

struct HomeView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: HomeViewModel
    @FocusState private var focusedSearchField
    
    var body: some View {
        FancyScrollView(
            title: "",
            headerHeight: 240,
            scrollUpHeaderBehavior: .parallax,
            scrollDownHeaderBehavior: .sticky,
            header: {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.primaryColor)
                            .edgesIgnoringSafeArea(.top)
                        VStack {
                            Spacer().frame(height: 40)
                            Text("Каталог курсов")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(Color.backgroundColor)
                                .font(.mulishBoldFont(size: 20))
                            Spacer().frame(height: 10)
                            
                            SearchBarView(text: $viewModel.searchQuery,
                                          buttonColor: Color.backgroundColor,
                                          onCommit: {
                                viewModel.performGlobalSearch()
                                router.path.append(.courses)
                            })
                            .focused($focusedSearchField)
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Популярные направления")
                                        .padding(.horizontal)
                                        .foregroundStyle(Color.backgroundColor)
                                        .font(.mulishRegularFont(size: 14))
                                    Spacer()
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(viewModel.popularCategories, id: \.parent.id) { parent, child in
                                            PopularCategoryButton(category: child.name, iconUrl: parent.iconUrl) {
                                                viewModel.categoryClicked(categoryId: child.id, isParent: false, childrenIds: [], parentId: parent.id)
                                                router.path.append(.courses)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    Rectangle()
                        .frame(height: 10)
                        .foregroundStyle(
                            LinearGradient(stops: [
                                .init(color: Color.primaryColor, location: 0),
                                .init(color: Color.backgroundColor, location: 0.5),
                            ], startPoint: .top, endPoint: .bottom)
                        )
                }
            }
        ) {
            ZStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.categorizedData, id: \.parent.id) { data in
                                CategoryView(parentCategory: data.parent, categories: data.children) { categoryId in
                                    let parentId = data.parent.id
                                    viewModel.categoryClicked(categoryId: categoryId, isParent: parentId == categoryId, childrenIds: data.children.map { $0.id }, parentId: parentId)
                                    router.path.append(.courses)
                                }
                            }
                        }
                        .padding()
                    }
                }
                if focusedSearchField, !viewModel.searchQuery.isEmpty {
                    VStack {
                        if !viewModel.searchQuery.isEmpty && focusedSearchField {
                            withAnimation {
                                searchResultsView
                            }
                        }
                        Spacer()
                    }
                }
            }
            .background(Color.backgroundColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                focusedSearchField = false
            }
        }
        .background(Color.backgroundColor)
    }
    
    var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(viewModel.searchCategories, id: \.parent.id) { parent, child in
                Button(action: {
                    viewModel.categoryClicked(categoryId: child.id, isParent: false, childrenIds: [ child.id ], parentId: parent.id, isFromSearch: true)
                    router.path.append(.courses)
                }) {
                    HStack {
                        if let urlStr = parent.iconUrl, !urlStr.isEmpty {
                            KFImage(URL(string: urlStr))
                                .resizable()
                                .onFailure { error in
                                    print("Failed to load category image: \(error.localizedDescription)")
                                }
                                .renderingMode(.template)
                                .foregroundStyle(Color.backgroundColor)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 16, height: 16)
                                
                        }
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .foregroundStyle(Color.backgroundColor)
                                .font(.mulishRegularFont(size: 18))
                            Text(parent.name)
                                .foregroundStyle(Color.backgroundColor)
                                .font(.mulishLightFont(size: 14))
                        }
                        .padding(.horizontal, 4)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.tertiaryColor.opacity(0.9))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                }
            }
            
            Button {
                viewModel.performGlobalSearch()
                router.path.append(.courses)
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.backgroundColor)
                        .frame(width: 16, height: 16)
                    Text("Искать во всех курсах")
                        .foregroundStyle(Color.backgroundColor)
                        .font(.mulishRegularFont(size: 18))
                        .padding(8)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.tertiaryColor.opacity(0.9))
                .cornerRadius(8)
                .shadow(radius: 4)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel(fetchCategoriesUseCase: DependencyContainer().fetchCategoriesUseCase, fetchCoursesUseCase: DependencyContainer().fetchCoursesUseCase, fetchCourseMediaUseCase: DependencyContainer().fetchCourseMediaUseCase, favoritesManager: DependencyContainer().favoritesManager, authStateManager: DependencyContainer().authStateManager))
}

struct PopularCategoryButton: View {
    var category: String
    var iconUrl: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let iconUrl, let url = URL(string: iconUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.backgroundColor)
                    } placeholder: {
                        Spacer()
                    }
                    .frame(width: 18, height: 18)
                }
                Text(category)
                    .font(.mulishLightFont(size: 13))
                    .foregroundStyle(Color.backgroundColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.secondaryColor)
            .cornerRadius(12)
            .padding(2)
        }
    }
}
