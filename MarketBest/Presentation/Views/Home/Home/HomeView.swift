//
//  LibraryView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text("Каталог курсов")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(Color.primaryColor)
                .font(.mulishBoldFont(size: 20))
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.categorizedData, id: \.parent.id) { data in
                        CategoryView(parentCategory: data.parent, categories: data.children) { categoryId in
                            print("Category clicked: \(categoryId)")
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel(fetchCategoriesUseCase: DependencyContainer().fetchCategoriesUseCase))
}
