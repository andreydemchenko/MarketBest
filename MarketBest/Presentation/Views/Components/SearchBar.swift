//
//  SearchBar.swift
//  MarketBest
//
//  Created by Macbook Pro on 25.04.2024.
//

import Foundation
import SwiftUI
import Combine

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Найти курс..."
    var buttonColor: Color = Color.primaryColor
    var onCommit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            TextField("", text: $text, onCommit: onCommit)
                .padding(8)
                .padding(.horizontal, 25)
                .foregroundStyle(Color.primaryColor)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(Color.primaryColor.opacity(0.6))
                        .font(.mulishRegularFont(size: 16))
                        .padding(.leading, 33)
                }
                .focused($isFocused)
                .submitLabel(.search)
                .background(Color.backgroundColor)
                .tint(Color.primaryColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.primaryColor)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isFocused {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(Color.primaryColor)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryColor, lineWidth: 2)
                )
                .onTapGesture {
                    withAnimation {
                        self.isFocused = true
                    }
                }
            
            if isFocused {
                Button(action: {
                    withAnimation {
                        self.isFocused = false
                        self.text = ""
                        UIApplication.shared.endEditing()
                    }
                }) {
                    Text("Отмена")
                        .font(.mulishLightFont(size: 14))
                        .foregroundStyle(buttonColor)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
