//
//  MyCoursesView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI
import NavigationBackport
import PopupView

struct MyCoursesView: View {
    
    @EnvironmentObject var viewModel: MyCoursesViewModel
    @EnvironmentObject var router: Router
    
    @State private var selectedTab: MyCoursesViewModel.CourseStatusCategory = .active
    @State private var selectedTabIndex = 0
    @State private var scrollToTabId: Int? = nil
    
    var body: some View {
        VStack {
            if viewModel.showNeedToLoginView {
                VStack {
                    
                }
                .popup(isPresented: $viewModel.showNeedToLoginView) {
                    VStack {
                        Text("Войдите или зарегистрируйтесь")
                            .foregroundStyle(Color.backgroundColor)
                            .font(.mulishBoldFont(size: 20))
                            .multilineTextAlignment(.center)
                        Text("чтобы видеть ваши курсы")
                            .foregroundStyle(Color.backgroundColor)
                            .font(.mulishLightFont(size: 14))
                        Button(action: {
                            router.showSignUp = false
                            router.selectedTab = .profile
                        }, label: {
                            Text("Войти")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(Color.backgroundColor)
                                .background(Color.accentColor)
                                .font(.mulishBoldFont(size: 18))
                                .cornerRadius(16)
                                .shadow(radius: 4)
                        })
                        .padding(.top, 12)
                    }
                    .frame(maxWidth: 280)
                    .padding()
                    .background(Color.primaryColor)
                    .clipShape(RoundedCorner(radius: 18))
                    .shadow(color: Color.primaryColor, radius: 4)
                } customize: {
                    $0
                        .dragToDismiss(false)
                        .closeOnTap(false)
                        .appearFrom(.top)
                        .animation(.bouncy)
                }
            } else {
                contentView
                    .onAppear {
                        Task {
                            await viewModel.fetchMyCourses()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor.ignoresSafeArea())

    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            Text("Мои курсы")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(Color.primaryColor)
                .font(.mulishBoldFont(size: 20))
            
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    HStack(spacing: 0) {
                        ForEach(Array(viewModel.categoriesToShow.enumerated()), id: \.element) { index, category in
                            CategoryTab(title: category.rawValue, count: viewModel.courses(for: category).count, isSelected: index == selectedTabIndex)
                                .id(index)
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        selectedTabIndex = index
                                        scrollToTabId = index
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: scrollToTabId) { targetId in
                        if let targetId {
                            scrollView.scrollTo(targetId, anchor: .center)
                        }
                    }
                    .animation(.default, value: selectedTabIndex)
                }
            }
            ZStack {
                CustomPagingView(selectedTabIndex: $selectedTabIndex, categories: viewModel.categoriesToShow, views: viewModel.categoriesToShow.map { category in
                              AnyView(coursesPage(for: category))
                          })
                          .frame(maxWidth: .infinity, maxHeight: .infinity)
                          .onChange(of: selectedTabIndex) { newIndex in
                              scrollToTabId = newIndex
                          }
                
                VStack {
                    Spacer()
                    Button {
                        router.path.append(.addCourse)
                    } label: {
                        Text("Создать курс")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(Color.backgroundColor)
                            .font(.mulishBoldFont(size: 16))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                    .padding()
                    Spacer()
                        .frame(height: 120)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func coursesPage(for category: MyCoursesViewModel.CourseStatusCategory) -> some View {
        ScrollView {
            Spacer()
                .frame(height: 40)
            ForEach(viewModel.courses(for: category), id: \.id) { course in
                MyCourseItemView(item: course, onEdit: {
                    if !viewModel.isLoadingMedia {
                        router.path.append(.editCourse(course: course))
                    }
                }, onOpenDetails: {
                    if !viewModel.isLoadingMedia {
                        router.path.append(.courseDetails(course: course))
                    }
                })
            }
            Spacer()
                .frame(maxHeight: .infinity)
        }
    }
    
    struct CategoryTab: View {
        var title: String
        var count: Int
        var isSelected: Bool

        var body: some View {
            VStack(alignment: .center) {
                HStack {
                    Text(title)
                        .font(.mulishBoldFont(size: 20))
                        .foregroundColor(isSelected ? Color.accentColor : Color.primaryColor)
                        .padding(.vertical, 10)
                        .animation(.default, value: isSelected)
                    
                    VStack {
                        Text("\(count)")
                            .font(.mulishLightFont(size: 12))
                            .foregroundColor(isSelected ? Color.accentColor : Color.primaryColor)
                            .animation(.default, value: isSelected)
                            .padding([.top, .trailing], 12)
                     Spacer()
                    }
                }
                .padding(.horizontal, 4)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 3)
                    .foregroundColor(isSelected ? Color.accentColor : Color.primaryColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
    }

}

struct CustomPagingView: View {
    @Binding var selectedTabIndex: Int
    let categories: [MyCoursesViewModel.CourseStatusCategory]
    let views: [AnyView]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(views.enumerated()), id: \.offset) { index, view in
                        view
                            .frame(width: geometry.size.width)
                            .clipped()
                    }
                }
            }
            .content.offset(x: -CGFloat(selectedTabIndex) * geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .gesture(
                DragGesture().onEnded { value in
                    let offset = value.translation.width / geometry.size.width
                    let velocity = value.predictedEndTranslation.width / geometry.size.width
                    let newIndex = (CGFloat(selectedTabIndex) - (offset + velocity * 0.5)).rounded()
                    selectedTabIndex = max(0, min(Int(newIndex), views.count - 1))
                }
            )
            .animation(.easeOut(duration: 0.3), value: selectedTabIndex)
        }
    }
}


#Preview {
    MyCoursesView()
        .environmentObject(Router(container: DependencyContainer(), authStateManager: DependencyContainer().authStateManager))
        .environmentObject(MyCoursesViewModel(fetchMyCoursesUseCase: DependencyContainer().fetchMyCoursesUseCase, fetchCategoriesUseCase: DependencyContainer().fetchCategoriesUseCase, fetchCourseMediaUseCase: DependencyContainer().fetchCourseMediaUseCase, authStateManager: DependencyContainer().authStateManager))
}
