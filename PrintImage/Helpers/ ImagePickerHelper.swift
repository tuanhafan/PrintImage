//
//   ImagePickerHelper.swift
//  PrintImage
//
//  Created by Alex Tran on 21/7/25.
//

import Foundation
import UIKit
import PhotosUI


class ImagePickerHelper: NSObject, PHPickerViewControllerDelegate {

    private weak var presentationController: UIViewController?
    private var completion: (([UIImage]) -> Void)?

    init(presentationController: UIViewController) {
        self.presentationController = presentationController
    }

    func presentImagePicker(completion: @escaping ([UIImage]) -> Void) {
        self.completion = completion

        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 = không giới hạn số lượng ảnh
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presentationController?.present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        var selectedImages: [UIImage] = []
        let group = DispatchGroup()

        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            self.completion?(selectedImages)
        }
    }
}

