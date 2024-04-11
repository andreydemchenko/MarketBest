//
//  MainView.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import SwiftUI
import NavigationBackport

struct MainView: View {
    @EnvironmentObject var router: Router
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    @State private var selectedTab: Tab = Tab.home
    
    
    var body: some View {
        NBNavigationStack(path: $router.path) {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    router.route(to: .library)
                    router.route(to: .favourites)
                    router.route(to: .myCourses)
                    router.route(to: .profile)
                }
                CustomBottomTabBarView(currentTab: $selectedTab)
                    .padding(.bottom)
            }
            .nbNavigationDestination(for: Screen.self) { screen in
                router.route(to: screen)
            }
        }
    }
}

enum Tab: String, Hashable, CaseIterable {
    case home = "Home"
    case favourites = "Favourites"
    case myCourses = "My courses"
    case profile = "Profile"
    
    var index: Int {
        return Self.allCases.firstIndex(of: self) ?? 0
    }
    
    var imageName: String {
        switch self {
        case .home:
            return "house.fill"
        case .favourites:
            return "heart.fill"
        case .myCourses:
            return "rectangle.fill.badge.plus"
        case .profile:
            return "person.fill"
        }
    }
}
