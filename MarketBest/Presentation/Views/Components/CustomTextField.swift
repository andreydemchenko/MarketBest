//
//  CustomTextField.swift
//  MarketBest
//
//  Created by Macbook Pro on 12.04.2024.
//

import SwiftUI
import Combine

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isNumber: Bool = false
    var isMultiline: Bool = false
    var keyboardType: UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType
    var onReturn: () -> Void
    @State private var isShowingPassword = false
    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: {
            isFocused = true
        }) {
            ZStack(alignment: .leading) {
                VStack {
                    Text(placeholder)
                        .font(.mulishLightFont(size: 14))
                        .opacity(text.isEmpty ? 0 : 1)
                        .foregroundColor(!text.isEmpty ? Color.primaryColor : Color.gray)
                        .padding(.leading, !text.isEmpty ? 12 : 24)
                        .scaleEffect(!text.isEmpty ? 0.8 : 1, anchor: .leading)
                        .offset(y: !text.isEmpty ? -20 : 0)
                        .animation(.easeInOut(duration: 0.2), value: !text.isEmpty)
                        .padding(.bottom, 12)
                    
                        Spacer()
                }
                
                Group {
                    if isMultiline {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $text)
                                .transparentScrolling()
                                .focused($isFocused)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .frame(minHeight: 100, maxHeight: 140)
                                .font(.mulishSemiBoldFont(size: 16))
                                .foregroundColor(Color.primaryColor)
                                .background(Color.backgroundColor)
                                .tint(Color.primaryColor)
                            
                            if text.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(Color.primaryColor.opacity(0.6))
                                    .font(.mulishRegularFont(size: 16))
                                    .padding(12)
                            }
                        }
                    } else {
                        if isSecure {
                            if isShowingPassword {
                                TextField("", text: $text)
                                    .keyboardType(keyboardType)
                            } else {
                                SecureField("", text: $text)
                                    .keyboardType(keyboardType)
                            }
                        } else {
                            TextField("", text: $text) { isEditing in
                                self.isFocused = isEditing
                            } onCommit: {
                                onReturn()
                            }
                            .keyboardType(isNumber ? .decimalPad : keyboardType)
                            .if(isNumber && !isMultiline) { view in
                                view.onReceive(Just(text)) { newValue in
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        self.text = filtered
                                    }
                                }
                            }
                        }
                    }
                }
                .onSubmit {
                    onReturn()
                }
                .font(.mulishSemiBoldFont(size: 16))
                .autocapitalization(.none)
                .placeholder(when: text.isEmpty) {
                    if !isMultiline {
                        Text(placeholder)
                            .foregroundColor(Color.primaryColor.opacity(0.6))
                            .font(.mulishRegularFont(size: 16))
                    }
                }
                .focused($isFocused)
                .submitLabel(returnKeyType == .next ? .next : .done)
                .padding(isMultiline ? 0 : 16)
                .foregroundColor(Color.primaryColor)
                .background(Color.backgroundColor)
                .tint(Color.primaryColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.clear : Color.primaryColor, lineWidth: 1)
                )
                .shadow(color: isFocused ? Color.accentColor : Color.clear, radius: 1, x: 1, y: 1)
                .overlay(
                    HStack {
                        Spacer()
                        if isSecure {
                            Button(action: {
                                isShowingPassword.toggle()
                            }) {
                                Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(Color.primaryColor)
                            }
                            .padding(.trailing, 16)
                        }
                    }
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .frame(height: isMultiline ? 100 : 60)
    }
}




//#Preview {
//    CustomTextField()
//}
