//
//  MyCourseItemView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI
import Kingfisher

struct MyCourseItemView: View {
    
    let item: CourseModel
    let onEdit: () -> Void
    let onOpenDetails: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryColor)
            
            HStack {
                if let urlStr = item.media.first?.url, let url = URL(string: urlStr) {
                    GeometryReader { geo in
                        ZStack {
//                            KFImage(url)
//                                .resizable()
//                                .cacheOriginalImage()
//                                .onFailure { error in
//                                    print("Failed to load image: \(error.localizedDescription)")
//                                }
//                                .placeholder {
//                                    KFImage(url)
//                                        .cacheMemoryOnly()
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: geo.size.width, height: geo.size.height)
//                                        .blur(radius: 10)
//                                        .cornerRadius(12, corners: [.bottomLeft, .topLeft])
//                                }
//                                .scaledToFill()
//                                .frame(width: geo.size.width, height: geo.size.height)
//                                .blur(radius: 5)
//                                .cornerRadius(12, corners: [.bottomLeft, .topLeft])
                            
                            KFImage(url)
                                .resizable()
                                .cacheOriginalImage()
                                .onFailure { error in
                                    print("Failed to load image: \(error.localizedDescription)")
                                }
                                .placeholder {
                                    KFImage(url)
                                        .cacheMemoryOnly()
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                }
                                .scaledToFill()
                                //.aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .cornerRadius(12, corners: [.bottomLeft, .topLeft])
                        }
                    }
                    .frame(width: 100, height: 100)
                } else {
                    Image("image_placeholder")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12, corners: [.bottomLeft, .topLeft])
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            if item.status == .moderation {
                                Text("На проверке")
                                    .font(.mulishLightFont(size: 12))
                                    .foregroundStyle(.yellow)
                            } else if item.status == .rejected {
                                Text("Отклонено")
                                    .font(.mulishLightFont(size: 12))
                                    .foregroundStyle(Color.accentColor)
                            }
                            
                            Text(item.name)
                                .font(.mulishBoldFont(size: 20))
                                .foregroundStyle(Color.backgroundColor)
                            
                            if item.status == .moderation || item.status == .rejected {
                                Spacer()
                                    .frame(height: 14)
                            }
                        }
                        //.foregroundStyle(Color.accentColor)
                        .font(.mulishBoldFont(size: 16))
                        .minimumScaleFactor(0.5)
                        Spacer()
                        Button {
                            onEdit()
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.backgroundColor)
                        }
                    }
                    Spacer()
                    HStack {
                        Text("\(item.price.rounded(toPlaces: 1).removeZerosFromEnd()) ₽")
                            .font(.mulishBoldFont(size: 16))
                            .foregroundStyle(Color.backgroundColor)
                        Spacer()
                        Text(item.categoryName)
                            .font(.mulishLightFont(size: 12))
                            .foregroundStyle(Color.backgroundColor)
                    }
                }
                .padding(.leading, 4)
                .padding(.trailing, 16)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .shadow(color: Color.primaryColor.opacity(0.4), radius: 6, y: 4)
        .padding(.vertical, 4)
        .padding(.horizontal)
        .onTapGesture {
            onOpenDetails()
        }
    }
}

#Preview {
    MyCourseItemView(
        item: CourseModel(id: UUID(), categoryId: UUID(), userId: UUID(), name: "Name some text some text", description: "Description", price: 25000, materialsText: "some text", materialsUrl: "https://aa.aa", status: .moderation, createdAt: Date(), updatedAt: Date(), categoryName: "category"),
        onEdit: { },
        onOpenDetails: { }
    )
}
