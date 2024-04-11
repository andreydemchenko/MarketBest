//
//  CustomTabBar.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation
import SwiftUI

private let buttonDimen: CGFloat = 55

struct CustomBottomTabBarView: View {
    
    @Binding var currentTab: Tab
    
    var body: some View {
        HStack {
        
            TabBarButton(imageName: Tab.home.imageName)
                .frame(width: buttonDimen, height: buttonDimen)
                .padding(.leading, 4)
                .onTapGesture {
                    currentTab = .home
                }
            
            Spacer()

            TabBarButton(imageName: Tab.favourites.imageName)
                .frame(width: buttonDimen, height: buttonDimen)
                .onTapGesture {
                    currentTab = .favourites
                }

            Spacer()
            
            TabBarButton(imageName: Tab.myCourses.imageName)
                .frame(width: buttonDimen, height: buttonDimen)
                .onTapGesture {
                    currentTab = .myCourses
                }

            Spacer()
            
            TabBarButton(imageName: Tab.profile.imageName)
                .frame(width: buttonDimen, height: buttonDimen)
                .padding(.trailing, 4)
                .onTapGesture {
                    currentTab = .profile
                }

        }
        .frame(width: (buttonDimen * CGFloat(Tab.allCases.count)) + 60)
        .tint(Color.primaryColor)
        .padding(.vertical, 2.5)
        .background(Color.secondaryColor)
        .clipShape(Capsule(style: .continuous))
        .overlay {
            SelectedTabCircleView(currentTab: $currentTab)
        }
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 10)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.65), value: currentTab)
    }
    
}

private struct TabBarButton: View {
    let imageName: String
    var body: some View {
        Image(systemName: imageName)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.accentColor)
            .frame(width: 25, height: 25)
            //.fontWeight(.bold)
    }
}

struct SelectedTabCircleView: View {
    
    @Binding var currentTab: Tab
    
    private var horizontalOffset: CGFloat {
        let totalWidth = buttonDimen * CGFloat(Tab.allCases.count) + 70 // Предполагаем, что 60 - это общее пространство для отступов.
        let tabWidth = totalWidth / CGFloat(Tab.allCases.count)
        let centerOffset = tabWidth * CGFloat(currentTab.index) + (tabWidth / 2) - (totalWidth / 2)
        return centerOffset
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.redColor)
                .frame(width: buttonDimen , height: buttonDimen)
            
            TabBarButton(imageName: currentTab.imageName)
                .foregroundStyle(Color.primaryColor)
        }
        .offset(x: horizontalOffset)
    }

}
