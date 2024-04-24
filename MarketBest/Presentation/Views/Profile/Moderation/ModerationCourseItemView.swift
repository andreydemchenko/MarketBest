//
//  ModerationCourseItemView.swift
//  MarketBest
//
//  Created by Macbook Pro on 14.04.2024.
//

import SwiftUI
import Kingfisher

struct ModerationCourseItemView: View {
    let item: CourseModel
    let onOpenDetails: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryColor)
            
            HStack {
                if let url = URL(string: item.media.first?.url ?? "") {
                    KFImage(url)
                        .resizable()
                        .cacheOriginalImage() // Ensures the original image is cached
                        .onFailure { error in
                            print("Failed to load image: \(error.localizedDescription)")
                        }
                        // Avoid showing the placeholder if the image is already in cache
                        .placeholder {
                            KFImage(url)
                                .cacheMemoryOnly() // Ensures the image is fetched from memory, fast retrieval
                                .onSuccess { result in
                                    // Image is in cache, no need for placeholder
                                }
                                .onFailure { _ in
                                    
                                }
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(12, corners: [.bottomLeft, .topLeft])
                        }
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12, corners: [.bottomLeft, .topLeft])
                } else {
                    Image("image_placeholder").resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12, corners: [.bottomLeft, .topLeft])
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.name)
                        //.foregroundStyle(Color.accentColor)
                            .font(.mulishBoldFont(size: 16))
                            .minimumScaleFactor(0.5)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("\(item.price.rounded(toPlaces: 1).removeZerosFromEnd()) ₽")
                            .font(.mulishBoldFont(size: 16))
                        Spacer()
                        Text(item.categoryName)
                            .font(.mulishLightFont(size: 12))
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .onTapGesture {
            onOpenDetails()
        }
    }
}

#Preview {
    ModerationCourseItemView(item: CourseModel(id: UUID(), categoryId: UUID(), userId: UUID(), name: "Name some text some text", description: "Description", price: 25000, materialsText: "some text", materialsUrl: "https://aa.aa", status: .moderation, createdAt: Date(), updatedAt: Date(), parentCategoryName: "", categoryName: "category"), onOpenDetails: { })
}
