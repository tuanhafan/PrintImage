//
//  UIView.swift
//  PrintImage
//
//  Created by Alex Tran on 6/8/25.
//

import Foundation
import UIKit

extension UIView {
    private var loadingOverlayTag: Int { return 999999 }

    func showLoading() {
        // Tránh tạo trùng
        if self.viewWithTag(loadingOverlayTag) != nil { return }

        // Overlay nền mờ
        let overlay = UIView()
        overlay.backgroundColor = UIColor.darkGray.withAlphaComponent(1)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.tag = loadingOverlayTag

        // Indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        overlay.addSubview(indicator)
        self.addSubview(overlay)

        // Ràng buộc cho overlay = full view
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: self.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
    }

    func hideLoading() {
        if let overlay = self.viewWithTag(loadingOverlayTag) {
            overlay.removeFromSuperview()
        }
    }
}

