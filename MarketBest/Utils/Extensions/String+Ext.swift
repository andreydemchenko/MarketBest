//
//  String+Ext.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword(requiredLength: Int = 6) -> Bool {
        return self.count >= requiredLength
    }
    
}
