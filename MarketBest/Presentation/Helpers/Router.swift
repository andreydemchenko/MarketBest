//
//  Router.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation
import SwiftUI
import NavigationBackport

enum Screen: NBScreen {
    case myCourses
    case addCourse
    case editCourse
    case profile
    case library
    case favourites
}

final class Router: ObservableObject {
    
    @Published var path: [Screen] = []
    
    let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
        Task {
            await container.authStateManager.fetchCurrentUser()
        }
    }
    
    @ViewBuilder
    func route(to screen: Screen) -> some View {
        switch screen {
        case .myCourses:
            MyCoursesView()
                .tag(Tab.myCourses)
                .environmentObject(self)
                .environmentObject(MyCoursesViewModel(fetchMyCoursesUseCase: container.fetchMyCoursesUseCase, userId: container.authStateManager.currentUser?.id ?? UUID()))
            
        case .addCourse:
            AddEditCourseView()
                .environmentObject(self)
                .environmentObject(
                    AddEditCourseViewModel(
                        createCourseUseCase: container.createCourseUseCase,
                        editCourseUseCase: container.editCourseUseCase,
                        userId: container.authStateManager.currentUser!.id)
                )
            
        case .editCourse:
            AddEditCourseView()
                .environmentObject(self)
                .environmentObject(
                    AddEditCourseViewModel(
                        createCourseUseCase: container.createCourseUseCase,
                        editCourseUseCase: container.editCourseUseCase,
                        userId: container.authStateManager.currentUser?.id ?? UUID())
                )
            
        case .profile:
            ProfileWrapperView()
                .tag(Tab.profile)
                .environmentObject(container)
                .environmentObject(container.authStateManager)
            
        case .library:
            LibraryView()
                .tag(Tab.home)
            
        case .favourites:
            FavouritesView()
                .tag(Tab.favourites)
        }
    }
}
