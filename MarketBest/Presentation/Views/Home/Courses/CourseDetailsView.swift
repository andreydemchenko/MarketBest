//
//  CourseDetailsView.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import SwiftUI
import FancyScrollView
import ACarousel
import Kingfisher

struct CourseDetailsView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: CourseDetailsViewModel
    @State private var isAnimating: Bool = false
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        ZStack {
            FancyScrollView(
                title: viewModel.course.name,
                titleColor: Color.primaryColor,
                headerHeight: 400,
                scrollUpHeaderBehavior: .parallax,
                scrollDownHeaderBehavior: .offset,
                header: {
                    headerView
                }
            ) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Категория")
                                .font(.mulishLightFont(size: 14))
                                .foregroundStyle(Color.primaryColor)
                            HStack {
                                if let iconUrl = viewModel.course.parentCategoryIconUrl, let url = URL(string: iconUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Spacer()
                                    }
                                    .frame(width: 20, height: 20)
                                }
                                Text("\(viewModel.course.parentCategoryName) > \(viewModel.course.categoryName)")
                                    .font(.mulishRegularFont(size: 16))
                                    .foregroundStyle(Color.primaryColor)
                                Spacer()
                            }
                        }
                        Spacer()
                        Button {
                            viewModel.toggleFavorite()
                        } label: {
                            Image(systemName: viewModel.isFavouriteCourse() ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(8)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Цена")
                            .font(.mulishLightFont(size: 14))
                            .foregroundStyle(Color.primaryColor)
                        Text("\(viewModel.course.price.removeZerosFromEnd()) ₽")
                            .font(.mulishRegularFont(size: 18))
                            .foregroundStyle(Color.primaryColor)
                    }
                    if let description = viewModel.course.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Описание")
                                .font(.mulishLightFont(size: 14))
                                .foregroundStyle(Color.primaryColor)
                            Text(description)
                                .font(.mulishRegularFont(size: 18))
                                .foregroundStyle(Color.primaryColor)
                        }
                    }
                    Spacer()
                   
                    
                }
                .padding()
                .background(Color.backgroundColor)
            }
            VStack {
                Spacer()
                Button {
                    
                } label: {
                    Text("Купить курс")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.backgroundColor)
                        .font(.mulishBoldFont(size: 18))
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
    
    var headerView: some View {
        ZStack(alignment: .bottomTrailing) {
            let media = viewModel.course.media
            if media.count > 0 {
                ACarousel(media, index: $currentImageIndex, headspace: 20) { item in
                    ZStack {
                        KFImage(URL(string: item.url))
                            .resizable()
                            .onFailure { error in
                                print("Failed to load image: \(error.localizedDescription)")
                            }
                            .placeholder {
                                Image("image_placeholder").resizable()
                            }
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.trailing)
                        
                        if item.name == nil {
                            Image(systemName: "play.circle")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 40, height: 40)
                                .padding(12)
                                .foregroundStyle(Color.primaryColor)
                                .background(Color.backgroundColor.opacity(0.5))
                                .clipShape(Circle())
                                .shadow(color: Color.backgroundColor, radius: 6)
                        }
                    }
                    .onTapGesture {
                        if item.name == nil, let urlStr = item.videoUrl, let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding(.vertical, 40)
            }
            
            if media.count > 1 {
                Text("\(currentImageIndex + 1) / \(media.count)")
                    .foregroundStyle(Color.backgroundColor)
                    .font(.mulishRegularFont(size: 14))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.primaryColor.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                    .padding(.bottom, 20)
            }
        }
    }
}

//#Preview {
//    CourseDetailsView()
//}
