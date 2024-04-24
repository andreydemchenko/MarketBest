//
//  Router.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation
import SwiftUI
import NavigationBackport
import Combine

protocol Navigable: NBScreen {
    var rawValue: String { get }
}

enum Screen: Navigable {
    
    case myCourses
    case addCourse
    case editCourse(course: CourseModel)
    case myCourseDetails(course: CourseModel)
    case profile
    case library
    case favourites
    case moderation
    case moderationCourseDetails(course: CourseModel)
    case orders
    case payments
    case courses
    case courseDetails(course: CourseModel)
    
    var rawValue: String {
        switch self {
        case .myCourses:
            return "My Courses"
        case .addCourse:
            return "Add Course"
        case .editCourse(_):
            return "Edit Course"
        case .myCourseDetails(_):
            return "My Course Details"
        case .profile:
            return "Profile"
        case .library:
            return "Library"
        case .favourites:
            return "Favourites"
        case .moderation:
            return "Moderation"
        case .moderationCourseDetails(_):
            return "Moderation Course Details"
        case .orders:
            return "Orders"
        case .payments:
            return "Payments"
        case .courses:
            return "Courses"
        case .courseDetails(_):
            return "Course Details"
        }
    }
}

enum InnerScreen: Navigable {
    case courses
    
    var rawValue: String {
        switch self {
        case .courses:
            return "Courses"
        }
    }
}


final class Router: ObservableObject {
    
    @Published var path: [Screen] = []
    //@Published var innerPath: [InnerScreen] = []
    @Published var selectedTab: Tab = .home
    @Published var isLoading: Bool = true
    @Published var isAuthenticated: Bool = false
    @Published var showSignUp: Bool = false
    
    let container: DependencyContainer
    let authStateManager: AuthStateManager
    
    private lazy var profileViewModel = ProfileViewModel(
        signOutUseCase: container.signOutUseCase,
        fetchCoursesByStatusUseCase: container.fetchCoursesByStatusUseCase,
        fetchCategoriesUseCase: container.fetchCategoriesUseCase,
        fetchCourseMediaUseCase: container.fetchCourseMediaUseCase,
        authStateManager: container.authStateManager
    )
    
    private lazy var myCoursesViewModel = MyCoursesViewModel(
        fetchMyCoursesUseCase: container.fetchMyCoursesUseCase,
        fetchCategoriesUseCase: container.fetchCategoriesUseCase,
        fetchCourseMediaUseCase: container.fetchCourseMediaUseCase,
        authStateManager: container.authStateManager)
    
    private lazy var homeViewModel = HomeViewModel(
        fetchCategoriesUseCase: container.fetchCategoriesUseCase,
        fetchCoursesUseCase: container.fetchCoursesUseCase,
        fetchCourseMediaUseCase: container.fetchCourseMediaUseCase,
        favoritesManager: container.favoritesManager,
        authStateManager: container.authStateManager
    )
    
    private var addEditCourseViewModelCache: AddEditCourseViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DependencyContainer, authStateManager: AuthStateManager) {
        self.container = container
        self.authStateManager = authStateManager
        
        
        loadCurrentUser()
        
        authStateManager.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                guard let strongSelf = self else { return }
                
                strongSelf.isAuthenticated = (user != nil)
            }
            .store(in: &cancellables)
    }
    
    private func loadCurrentUser() {
        Task {
            await container.authStateManager.fetchCurrentUser()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    @ViewBuilder
    func route(to screen: Screen) -> some View {
        switch screen {
        case .myCourses:
            MyCoursesView()
                .tag(Tab.myCourses)
                .environmentObject(self)
                .environmentObject(myCoursesViewModel)
                .onAppear {
                    self.resetAddEditCourseViewModel()
                }
            
        case .addCourse:
            AddEditCourseView()
                .environmentObject(self)
                .environmentObject(
                   getAddEditCourseViewModel()
                )
            
        case .editCourse(let course):
            AddEditCourseView()
                .environmentObject(self)
                .environmentObject(getAddEditCourseViewModel(for: course))
            
        case .profile:
            if isAuthenticated {
                ProfileView()
                    .tag(Tab.profile)
                    .environmentObject(container.authStateManager)
                    .environmentObject(profileViewModel)
                    .environmentObject(self)
            } else {
                if showSignUp {
                    SignUpView()
                        .tag(Tab.profile)
                        .environmentObject(self)
                        .environmentObject(container.authStateManager)
                        .environmentObject(AuthViewModel(signUpUseCase: container.signUpUseCase, signInUseCase: container.signInUseCase, createUserUseCase: container.createUserUseCase))
                } else {
                    SignInView()
                        .tag(Tab.profile)
                        .environmentObject(self)
                        .environmentObject(container.authStateManager)
                        .environmentObject(AuthViewModel(signUpUseCase: container.signUpUseCase, signInUseCase: container.signInUseCase, createUserUseCase: container.createUserUseCase))
                }
            }
            
        case .library:
            HomeView()
                .tag(Tab.home)
                .environmentObject(homeViewModel)
            
        case .favourites:
            FavouritesView()
                .tag(Tab.favourites)
            
        case .moderation:
            ModerationView()
                .environmentObject(profileViewModel)
                .environmentObject(self)
        case .orders:
            OrdersView()
        case .payments:
            PaymentsView()
            
        case .myCourseDetails(let course):
            MyCourseDetailsView()
                .environmentObject(
                    MyCourseDetailsViewModel(
                        course: course,
                        updateCourseStatusUseCase: container.updateCourseStatusUseCase,
                        deleteCourseUseCase: container.deleteCourseUseCase,
                        deleteMediaItemUseCase: container.deleteMediaItemUseCase, 
                        authStateManager: container.authStateManager
                    )
                )
            
        case .moderationCourseDetails(let course):
            ModerationCourseDetailsView()
                .environmentObject(ModerationCourseDetailsViewModel(course: course, updateCourseStatusUseCase: container.updateCourseStatusUseCase))
                .environmentObject(self)
            
        case .courses:
            CoursesView()
                .environmentObject(homeViewModel)
                .environmentObject(self)
            
        case .courseDetails(let course):
            CourseDetailsView()
                .environmentObject(self)
                .environmentObject(
                    CourseDetailsViewModel(course: course, favoritesManager: container.favoritesManager)
                )
        }
    }
//    
//    @ViewBuilder
//    func route(to screen: InnerScreen) -> some View {
//        switch screen {
//        case .courses:
//            CoursesView()
//                .environmentObject(homeViewModel)
//        }
//    }
    
    func getAddEditCourseViewModel(for course: CourseModel? = nil) -> AddEditCourseViewModel {
           if let viewModel = addEditCourseViewModelCache {
               return viewModel
           } else {
               let viewModel = AddEditCourseViewModel(
                   createCourseUseCase: container.createCourseUseCase,
                   editCourseUseCase: container.editCourseUseCase,
                   fetchCategoriesUseCase: container.fetchCategoriesUseCase,
                   courseMediaUseCases: container.courseMediaUseCases,
                   fetchVideoDetailsUseCase: container.fetchVideoDetailsUseCase,
                   authStateManager: container.authStateManager,
                   course: course
               )
               addEditCourseViewModelCache = viewModel
               return viewModel
           }
       }

       // Method to reset the ViewModel cache
       func resetAddEditCourseViewModel() {
           addEditCourseViewModelCache = nil
       }
}
