//
//  SplashView.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .frame(width: 40, height: 40)
                .foregroundStyle(.black)
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading...")
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .background(.white)
    }
}

#Preview {
    SplashView()
}
