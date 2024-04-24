//
//  CourseItemView.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import SwiftUI
import Kingfisher

struct CourseItemView: View {
    
    let item: CourseModel
    let hasLoadedImage: Bool
    var isFavourite: Bool
    let onLike: () -> Void
    let onOpenDetails: () -> Void
    
    var body: some View {
        Button {
            onOpenDetails()
        } label: {
            VStack {
                if hasLoadedImage, let urlStr = item.media.first?.url {
                    GeometryReader { geo in
                        ZStack() {
                            KFImage(URL(string: urlStr))
                                .resizable()
                                .cacheOriginalImage()
                                .onFailure { error in
                                    print("Failed to load image: \(error.localizedDescription)")
                                }
                                .placeholder {
                                    KFImage(URL(string: urlStr))
                                        .cacheMemoryOnly()
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .blur(radius: 5)
                                        .cornerRadius(12, corners: [.topLeft, .topRight])
                                }
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .blur(radius: 5)
                                .cornerRadius(12, corners: [.topLeft, .topRight])
                                .shadow(radius: 4, y: 1)
                            
                            KFImage(URL(string: urlStr))
                                .resizable()
                                .cacheOriginalImage()
                                .onFailure { error in
                                    print("Failed to load image: \(error.localizedDescription)")
                                }
                                .placeholder {
                                    KFImage(URL(string: urlStr))
                                        .cacheMemoryOnly()
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    //                                    .frame(width: geo.size.width, height: geo.size.height)
                                }
                                .aspectRatio(contentMode: .fit)
                            //                            .frame(width: geo.size.width, height: geo.size.height)
                                .cornerRadius(12, corners: [.topLeft, .topRight])
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        onLike()
                                    } label: {
                                        Image(systemName: isFavourite ? "heart.fill" : "heart")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .padding(8)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.top)
                        }
                    }
                    .frame(height: 180)
                } else {
                    Spacer().frame(height: 180)
                }
                
                HStack {
                    Text(item.name)
                        .font(.mulishBoldFont(size: 20))
                        .foregroundStyle(Color.tertiaryColor)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(4)
                
                HStack {
                    Text(item.categoryName)
                        .font(.mulishLightFont(size: 12))
                        .foregroundStyle(Color.primaryColor)
                    Spacer()
                    Text("\(item.price.rounded(toPlaces: 1).removeZerosFromEnd()) ₽")
                        .font(.mulishBoldFont(size: 20))
                        .foregroundStyle(Color.tertiaryColor)
                }
                .padding([.bottom, .trailing, .leading])
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .contentShape(Rectangle())
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.primaryColor, radius: 2)
        .padding(10)
    }
}

#Preview {
    CourseItemView(
        item: CourseModel(id: UUID(), categoryId: UUID(), userId: UUID(), name: "Name some text text text text some text", description: "Description", price: 25000, materialsText: "some text", materialsUrl: "https://aa.aa", status: .moderation, createdAt: Date(), updatedAt: Date(), media: [CourseMediaItem(id: UUID(), courseId: UUID(), name: "name", url: "https://iwadvsuujqxzxrmsjnsm.supabase.co/storage/v1/object/sign/courses/uploaded_image_77923CDD-40AC-4FDD-A5F4-F7EF8CB0032C.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJjb3Vyc2VzL3VwbG9hZGVkX2ltYWdlXzc3OTIzQ0RELTQwQUMtNEZERC1BNUY0LUY3RUY4Q0IwMDMyQy5qcGciLCJpYXQiOjE3MTMzODE0MzUsImV4cCI6MTgwNzk4OTQzNX0.I-VCIOP7nFDsWYehg8omacjSg-FHgrGgGQDozIwk_ic", order: 0, createdAt: Date())], categoryName: "category"),
        hasLoadedImage: true,
        isFavourite: true,
        onLike: { },
        onOpenDetails: { }
    )
}
