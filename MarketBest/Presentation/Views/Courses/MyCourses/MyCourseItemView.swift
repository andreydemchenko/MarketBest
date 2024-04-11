//
//  MyCourseItemView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI

struct MyCourseItemView: View {
    
    let item: CourseModel
    let onEdit: () -> Void
    let onOpenDetails: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.secondaryColor)
            
            HStack {
                AsyncImage(url: URL(string: "https://www.adobe.com/products/media_14562ad96c12a2f3030725ae81bd3ede1c68cb783.jpeg?width=750&format=jpeg&optimize=medium"),
                           scale: 3) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray
                            ProgressView()
                        }
                    case .success(let image):
                        image.resizable()
                    case .failure(let error):
                        Text(error.localizedDescription)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .cornerRadius(25, corners: [.bottomLeft, .topLeft])
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.name)
                        //.foregroundStyle(Color.accentColor)
                            .font(.title)
                            .minimumScaleFactor(0.5)
                        Spacer()
                        Button {
                            onEdit()
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.primaryColor)
                        }
                    }
                       
                    HStack {
                        Spacer()
                        Text("\(item.price.rounded(toPlaces: 1).removeZerosFromEnd()) ₽")
                            .font(.headline)
                        //.foregroundStyle(Color.red)
                    }
                }
                .padding(.leading, 4)
                .padding(.trailing, 16)
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .shadow(color: Color.secondary, radius: 4)
        .onTapGesture {
            onOpenDetails()
        }
    }
}

#Preview {
    MyCourseItemView(
        item: CourseModel(id: UUID(), userId: UUID(), name: "Name some text some text", description: "Description", price: 25000, materialsText: "some text", materialsUrl: "https://aa.aa", status: .active, createdAt: Date()),
        onEdit: { },
        onOpenDetails: { }
    )
}
