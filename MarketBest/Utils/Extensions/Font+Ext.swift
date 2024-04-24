//
//  Font+Ext.swift
//  MarketBest
//
//  Created by Macbook Pro on 13.04.2024.
//

import Foundation
import SwiftUI

extension Font {
    
    static func mulishLightFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.mulishLight, size: size)
    }
    
    static func mulishRegularFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.mulishRegular, size: size)
    }
    
    static func mulishMediumFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.mulishMedium, size: size)
    }
    
    static func mulishSemiBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.mulishSemiBold, size: size)
    }
    
    static func mulishBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.mulishBold, size: size)
    }
    
    static func mulishExtraBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.mulishExtraBold, size: size)
    }
    
}
