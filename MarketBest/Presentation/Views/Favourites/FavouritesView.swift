//
//  FavouritesView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI

struct FavouritesView: View {
    var body: some View {
        VStack {
            Text("Избранное")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(Color.primaryColor)
                .font(.mulishBoldFont(size: 20))
            Spacer()
            Text("Скоро будет")
                .padding()
                .foregroundStyle(Color.primaryColor)
                .font(.mulishRegularFont(size: 16))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

#Preview {
    FavouritesView()
}
