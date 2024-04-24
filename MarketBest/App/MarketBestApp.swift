//
//  MarketBestApp.swift
//  MarketBest
//
//  Created by Macbook Pro on 08.04.2024.
//

import SwiftUI

@main
struct MarketBestApp: App {
    
    private let dependencyContainer = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(Router(container: dependencyContainer, authStateManager: dependencyContainer.authStateManager))
        }
    }
}
