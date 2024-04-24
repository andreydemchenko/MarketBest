//
//  Favourite.swift
//  MarketBest
//
//  Created by Macbook Pro on 23.04.2024.
//

import Foundation

struct FavouriteModel: SupabaseModel, IdentifiableModel {
    
    static let tableName = "favourites"
    
    let id: UUID
    let userId: UUID
    let courseId: UUID
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", courseId = "course_id", createdAt = "created_at"
    }
}
