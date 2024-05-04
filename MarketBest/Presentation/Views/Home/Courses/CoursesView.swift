//
//  CoursesView.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import SwiftUI
import Kingfisher

struct CoursesView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: HomeViewModel
    @FocusState private var focusedSearchField
    @State private var showHorizontalScrollViews = true
    @State private var scrollToParentCategoryID: UUID?

    private let rows: [GridItem] = Array(repeating: .init(.flexible(minimum: 40, maximum: 100), alignment: .leading), count: 2)
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 16) {
                    Button {
                        viewModel.clearData()
                        router.path.removeLast()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 12, height: 20)
                            .foregroundStyle(Color.primaryColor)
                    }
                    SearchBarView(text: $viewModel.searchQuery, onCommit: {
                        viewModel.performGlobalSearch()
                    })
                    .focused($focusedSearchField)
                }
                .padding(16)
                
                VStack {
                    VStack {
                        if showHorizontalScrollViews {
                            ScrollView(.horizontal, showsIndicators: false) {
                                ScrollViewReader { scrollProxy in
                                    HStack {
                                        ForEach(viewModel.categorizedData, id: \.parent.id) { data in
                                            CourseCategoryItem(category: data.parent.name, isParent: true, iconUrl: data.parent.iconUrl, isSelected: viewModel.selectedCategoryIds.contains(data.parent.id)) {
                                                viewModel.categoryClicked(categoryId: data.parent.id, isParent: true, childrenIds: data.children.map { $0.id }, parentId: nil)
                                            }
                                            .id(data.parent.id)
                                            .onAppear {
                                                if let scrollToParentCategoryID, data.parent.id == scrollToParentCategoryID {
                                                    scrollProxy.scrollTo(scrollToParentCategoryID, anchor: .center)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .onAppear {
                                        if let selectedParentId = viewModel.selectedParentCategoryId {
                                            scrollToParentCategoryID = selectedParentId
                                        }
                                    }
                                }
                            }
                            .frame(height: 40)
                            
                            if let selectedParentId = viewModel.selectedParentCategoryId, let children = viewModel.categorizedData.first(where: { $0.parent.id == selectedParentId })?.children {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 0) {
                                            ForEach(Array(children.indices.filter { $0 % 2 == 0 }), id: \.self) { index in
                                                let child = children[index]
                                                CourseCategoryItem(category: child.name, isParent: false, iconUrl: child.iconUrl, isSelected: viewModel.selectedCategoryIds.contains(child.id)) {
                                                    viewModel.categoryClicked(categoryId: child.id, isParent: false, childrenIds: [], parentId: nil)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        HStack(spacing: 0) {
                                            ForEach(Array(children.indices.filter { $0 % 2 != 0 }), id: \.self) { index in
                                                let child = children[index]
                                                CourseCategoryItem(category: child.name, isParent: false, iconUrl: child.iconUrl, isSelected: viewModel.selectedCategoryIds.contains(child.id)) {
                                                    viewModel.categoryClicked(categoryId: child.id, isParent: false, childrenIds: [], parentId: nil)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(minHeight: 74)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color.tertiaryColor.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 8)
                    
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scrollView")).origin.y)
                        }
                        ForEach(viewModel.courses, id: \.id) { course in
                            CourseItemView(
                                item: course,
                                hasLoadedImage: viewModel.hasLoadedMedia,
                                isFavourite: viewModel.isFavouriteCourse(id: course.id),
                                onLike: {
                                    viewModel.toggleFavorite(courseId: course.id)
                                },
                                onOpenDetails: {
                                    router.path.append(.courseDetails(course: course))
                                }
                            )
                        }
                        .padding(.horizontal)
                    }
                    .coordinateSpace(name: "scrollView")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        withAnimation {
                            showHorizontalScrollViews = offset > -100 // Adjust this value based on your needs
                        }
                    }
                }
                .overlay {
                    if focusedSearchField, !viewModel.searchQuery.isEmpty {
                        Color.backgroundColor
                            .opacity(0.5)
                            .animation(.easeInOut(duration: 0.5), value: focusedSearchField)
                    }
                }
            }
            
            if focusedSearchField, !viewModel.searchQuery.isEmpty {
                VStack {
                    Spacer().frame(height: 80)
                    if !viewModel.searchQuery.isEmpty && focusedSearchField {
                        withAnimation {
                            searchResultsView
                        }
                    }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                focusedSearchField = false
            }
        }
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden(true)
    }
    
    var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(viewModel.searchCategories, id: \.parent.id) { parent, child in
                Button(action: {
                    focusedSearchField = false
                    viewModel.categoryClicked(categoryId: child.id, isParent: false, childrenIds: [ child.id ], parentId: parent.id, isFromSearch: true)
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
                focusedSearchField = false
                viewModel.performGlobalSearch()
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
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: focusedSearchField)
        }
        .padding(.horizontal)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct CourseCategoryItem: View {
    var category: String
    let isParent: Bool
    var iconUrl: String?
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let iconUrl = iconUrl, let url = URL(string: iconUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .renderingMode(.template)
                            .foregroundStyle(isSelected ? Color.backgroundColor : Color.primaryColor)
                    } placeholder: {
                        Spacer()
                    }
                    .frame(width: 20, height: 20)
                }
                Text(category)
                    .font(isParent ? .mulishRegularFont(size: 14) : .mulishLightFont(size: 12))
                    .foregroundStyle(isSelected ? Color.backgroundColor : Color.primaryColor)
                
                if isSelected {
                    Image(systemName: "xmark")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.backgroundColor)
                        .padding(4)
                }
            }
            .padding(6)
            .background(isSelected ? (isParent ? Color.primaryColor : Color.primaryColor.opacity(0.8) ) : Color.clear)
            .cornerRadius(20)
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(isSelected ? Color.clear : Color.primaryColor, lineWidth: 1)
//            )
            .padding(2)
        }
        .contentShape(Rectangle())
        .animation(.easeInOut, value: isSelected)
        .padding(2)
    }
}


//#Preview {
//    CoursesView()
//}
