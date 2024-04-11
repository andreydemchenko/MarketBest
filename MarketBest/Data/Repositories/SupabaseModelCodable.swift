//
//  SupabaseModel.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

protocol SupabaseModel: Codable {
    static var tableName: String { get }
    var id: UUID { get }
}
