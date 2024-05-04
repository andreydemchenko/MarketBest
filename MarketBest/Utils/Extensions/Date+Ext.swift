//
//  Date+Ext.swift
//  MarketBest
//
//  Created by Macbook Pro on 19.04.2024.
//

import Foundation

extension Date {
    
    var toSupabaseString: String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
    
    func toLocalDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, HH:mm"
        return formatter.string(from: self)
    }
}
