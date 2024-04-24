//
//  ModerationCourseDetailsView.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import SwiftUI
import FancyScrollView
import ACarousel
import Kingfisher

struct ModerationCourseDetailsView: View {
    @EnvironmentObject var viewModel: ModerationCourseDetailsViewModel
    @EnvironmentObject var router: Router
    
    @State private var isAnimating: Bool = false
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        FancyScrollView(
            title: viewModel.course.name,
            titleColor: Color.backgroundColor,
            headerHeight: 400,
            scrollUpHeaderBehavior: .parallax,
            scrollDownHeaderBehavior: .offset,
            header: {
                headerView
            }
        ) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Категория")
                        .font(.mulishLightFont(size: 12))
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
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Цена")
                        .font(.mulishLightFont(size: 12))
                        .foregroundStyle(Color.primaryColor)
                    Text("\(viewModel.course.price.removeZerosFromEnd()) ₽")
                        .font(.mulishRegularFont(size: 16))
                        .foregroundStyle(Color.primaryColor)
                }
                if let description = viewModel.course.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Описание")
                            .font(.mulishLightFont(size: 12))
                            .foregroundStyle(Color.primaryColor)
                        Text(description)
                            .font(.mulishRegularFont(size: 16))
                            .foregroundStyle(Color.primaryColor)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ссылка после оплаты")
                        .font(.mulishLightFont(size: 12))
                        .foregroundStyle(Color.primaryColor)
                    Text(viewModel.course.materialsUrl)
                        .font(.mulishRegularFont(size: 16))
                        .foregroundStyle(Color.primaryColor)
                }
                if let materials = viewModel.course.materialsText, !materials.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Материалы")
                            .font(.mulishLightFont(size: 12))
                            .foregroundStyle(Color.primaryColor)
                        Text(materials)
                            .font(.mulishRegularFont(size: 16))
                            .foregroundStyle(Color.primaryColor)
                    }
                }
                HStack {
                    Button {
                        Task {
                            await viewModel.rejectCourse()
                            DispatchQueue.main.async {
                                self.router.path.removeLast()
                            }
                        }
                    } label: {
                        Text("Отклонить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(Color.tertiaryColor)
                            .font(.mulishBoldFont(size: 16))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                    Button {
                        Task {
                            await viewModel.acceptCourse()
                            DispatchQueue.main.async {
                                self.router.path.removeLast()
                            }
                        }
                    } label: {
                        Text("Одобрить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColor)
                            .foregroundStyle(Color.backgroundColor)
                            .font(.mulishBoldFont(size: 16))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                }
            }
            .padding()
            .background(Color.backgroundColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .overlay {
            ZStack {
                if viewModel.isLoading {
                    Color.primaryColor.opacity(0.3).edgesIgnoringSafeArea(.all)
                    BarsLoader(isAnimating: $isAnimating, color: Color.tertiaryColor)
                        .frame(width: 50, height: 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
        }
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

#Preview {
    ModerationCourseDetailsView()
}
