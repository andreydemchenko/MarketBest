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
        
            TabBarButton(imageName: Tab.home.imageName, name: Tab.home.title, isSelected: currentTab == .home)
                .frame(width: buttonDimen, height: buttonDimen)
                .padding(.leading, 4)
                .onTapGesture {
                    currentTab = .home
                }
            
            Spacer()

            TabBarButton(imageName: Tab.favourites.imageName, name: Tab.favourites.title, isSelected: currentTab == .favourites)
                .frame(width: buttonDimen, height: buttonDimen)
                .onTapGesture {
                    currentTab = .favourites
                }

            Spacer()
            
            TabBarButton(imageName: Tab.myCourses.imageName, name: Tab.myCourses.title, isSelected: currentTab == .myCourses)
                .frame(width: buttonDimen, height: buttonDimen)
                .onTapGesture {
                    currentTab = .myCourses
                }

            Spacer()
            
            TabBarButton(imageName: Tab.profile.imageName, name: Tab.profile.title, isSelected: currentTab == .profile)
                .frame(width: buttonDimen, height: buttonDimen)
                .padding(.trailing, 4)
                .onTapGesture {
                    withAnimation {
                        currentTab = .profile
                    }
                }

        }
        .frame(width: (buttonDimen * CGFloat(Tab.allCases.count)) + 70)
        .padding(.vertical, 2.5)
        .background(
            SelectedTabView(currentTab: $currentTab)
        )
        .background(Color.primaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.tertiaryColor.opacity(0.6), radius: 5, x: 0, y: 10)
    }
    
}

private struct TabBarButton: View {
    let imageName: String
    let name: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(isSelected ? Color.accentColor : Color.backgroundColor)
                .frame(width: 25, height: 25)
            Text(name)
                .font(.mulishLightFont(size: 10))
                .foregroundStyle(Color.backgroundColor)
                
        }
    }
}

struct SelectedTabView: View {
    
    @Binding var currentTab: Tab
    
    private var horizontalOffset: CGFloat {
        let totalWidth = buttonDimen * CGFloat(Tab.allCases.count) + 80
        let tabWidth = totalWidth / CGFloat(Tab.allCases.count)
        let centerOffset = tabWidth * CGFloat(currentTab.index) + (tabWidth / 2) - (totalWidth / 2)
        return centerOffset
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tertiaryColor)
                .frame(width: buttonDimen , height: buttonDimen)
            
//            TabBarButton(imageName: currentTab.imageName, name: currentTab.title)
//                .foregroundStyle(Color.primaryColor)
        }
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.65), value: currentTab)
        .offset(x: horizontalOffset)
    }

}
