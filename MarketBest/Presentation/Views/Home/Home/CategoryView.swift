//
//  CategoryView.swift
//  MarketBest
//
//  Created by Macbook Pro on 22.04.2024.
//

import SwiftUI
import Kingfisher

struct CategoryView: View {
    
    let parentCategory: CategoryModel
    let categories: [CategoryModel]
    let onCategoryClick: (UUID) -> Void
    
    var body: some View {
        VStack {
            KFImage(URL(string: parentCategory.iconUrl ?? ""))
                .resizable()
                .onFailure { error in
                    print("Failed to load category image: \(error.localizedDescription)")
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .padding(.top)
            Text(parentCategory.name)
                .font(.mulishBoldFont(size: 20))
                .foregroundStyle(Color.accentColor)
                .padding(16)
            ForEach(categories, id: \.id) { item in
                CategoryItemView(item: item, onClick: onCategoryClick)
            }
            Spacer()
            Button {
                onCategoryClick(parentCategory.id)
            } label: {
                HStack {
                    Image(systemName: "books.vertical.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 16, height: 16)
                        .padding(.trailing, 10)

                    Text("Смотреть все курсы")
                        .font(.mulishRegularFont(size: 15))
                        .foregroundStyle(Color.accentColor)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .frame(width: 220, height: 420)
        .padding(8)
        .contentShape(Rectangle())
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.primaryColor, radius: 2)
        .padding(10)
    }

}

struct CategoryItemView: View {
    
    let item: CategoryModel
    let onClick: (UUID) -> Void
    
    var body: some View {
        Button {
            onClick(item.id)
        } label: {
            HStack {
                Image(systemName: "arrowtriangle.forward.fill")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 10, height: 14)
                    .padding(.trailing, 10)
                Text(item.name)
                    .font(.mulishRegularFont(size: 14))
                    .foregroundStyle(Color.primaryColor)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

//#Preview {
//    CategoryView(categories: [], onCategoryClick: {})
//}
