//
//  MainView.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import SwiftUI

struct MainView: View {
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        List {
            if container.authStateManager.canAccess(.viewCourses) {
                Text("Course List")
                // Display courses
            }
            if container.authStateManager.canAccess(.purchaseCourse) {
                Button("Purchase Course") {
                    // Handle purchase
                }
            }
            if container.authStateManager.canAccess(.createCourse) {
                Button("Create Course") {
                    // Navigate to create course screen
                }
            }
        }
    }
}
