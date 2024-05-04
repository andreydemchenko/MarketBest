//
//  String+Ext.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

extension String {
    
    func isValidName() -> Bool {
        return self.count >= 2
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword(requiredLength: Int = 6) -> Bool {
        return self.count >= requiredLength
    }
    
    func inflectCourseName() -> String {
        switch self.lowercased() {
        case "аналитика":
            return "аналитики"
        case "дизайн":
            return "дизайна"
        case "программирование":
            return "программировании"
        case "менеджмент":
            return "менеджмента"
        case "маркетинг":
            return "маркетинга"
        case "разработка":
            return "по разработке"
        default:
            return self
        }
    }
    
}
