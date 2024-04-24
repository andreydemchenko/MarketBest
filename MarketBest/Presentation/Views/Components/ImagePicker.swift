//
//  ImagePicker.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation
import SwiftUI
import PhotosUI


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images  // This restricts the picker to only show images.

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        self?.parent.selectedImageData = image.jpegData(compressionQuality: 0.8)
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
}

