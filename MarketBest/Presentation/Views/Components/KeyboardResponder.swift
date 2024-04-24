//
//  KeyboardResponder.swift
//  MarketBest
//
//  Created by Macbook Pro on 12.04.2024.
//

import Foundation
import UIKit
import SwiftUI
import Combine

//class KeyboardResponder: ObservableObject {
//    @Published var isVisible: Bool = false
//    private var notificationCenter: NotificationCenter
//
//    init(center: NotificationCenter = .default) {
//        notificationCenter = center
//        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    deinit {
//        notificationCenter.removeObserver(self)
//    }
//
//    @objc func keyboardWillShow(notification: Notification) {
//        isVisible = true
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//        isVisible = false
//    }
//}
//

struct KeyboardVisibilityAwareModifier: ViewModifier {
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    isVisible = false
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isVisible = true
                }
            }
    }
}



class KeyboardManager: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables: Set<AnyCancellable> = []

    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
    }
}
