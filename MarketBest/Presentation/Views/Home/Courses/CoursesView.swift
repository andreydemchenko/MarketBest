//
//  CoursesView.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import SwiftUI

struct CoursesView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: HomeViewModel
    
    private let rows: [GridItem] = Array(repeating: .init(.fixed(40)), count: 2) // Adjust height as needed
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    viewModel.clearData()
                    router.path.removeLast()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 14, height: 20)
                        .foregroundStyle(Color.primaryColor)
                }
                Spacer()
            }
            .padding(12)
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.categorizedData, id: \.parent.id) { data in
                            CourseCategoryItem(category: data.parent.name, isParent: true, iconUrl: data.parent.iconUrl, isSelected: viewModel.selectedCategoryIds.contains(data.parent.id)) {
                                viewModel.categoryClicked(categoryId: data.parent.id, isParent: true, childrenIds: data.children.map { $0.id }, parentId: nil)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 50)

                if let selectedParent = viewModel.selectedParentCategory, let children = viewModel.categorizedData.first(where: { $0.parent.id == selectedParent })?.children {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 2) {
                            ForEach(children, id: \.id) { child in
                                CourseCategoryItem(category: child.name, isParent: false, iconUrl: child.iconUrl, isSelected: viewModel.selectedCategoryIds.contains(child.id)) {
                                    viewModel.categoryClicked(categoryId: child.id, isParent: false, childrenIds: [], parentId: nil)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden(true)
    
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
            .padding(isSelected ? 6 : 2)
            .background(isSelected ? (isParent ? Color.primaryColor : Color.primaryColor.opacity(0.8) ) : Color.backgroundColor)
            .cornerRadius(20)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.primaryColor : Color.clear, lineWidth: isParent ? 2 : 1)
            )
        }
        .animation(.easeInOut, value: isSelected)
        .padding(2)
        .contentShape(Rectangle())
    }
}


//#Preview {
//    CoursesView()
//}
