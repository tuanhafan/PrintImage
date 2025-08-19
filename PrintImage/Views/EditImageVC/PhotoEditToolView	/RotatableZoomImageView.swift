//
//  RotatableZoomImageView.swift
//  PrintImage
//
//  Created by Alex Tran on 9/8/25.
//

import Foundation
import UIKit

final class RotatableZoomImageView: UIView {

    // MARK: - Subviews
    private let scrollView = UIScrollView()
     let imageView = UIImageView()

    // MARK: - State
    private var originalImage: UIImage?

    /// Nếu false thì disable pinch/pan, và zoomScale sẽ reset về 1.0
    var isZoomEnabled: Bool = true {
        didSet { updateZoomState() }
    }

    /// max zoom
    var maximumZoomScale: CGFloat = 5.0 {
        didSet { scrollView.maximumZoomScale = maximumZoomScale }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true

        // ScrollView
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        addSubview(scrollView)

        // ImageView
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        if originalImage != nil {
            layoutForImage()
        }
    }

    // MARK: - Public API
    func setImage(_ image: UIImage?) {
        originalImage = image
        imageView.image = image
        layoutForImage()
    }

    /// Lật ngang với animation
    func flipHorizontal(animated: Bool = true) {
            guard let current = imageView.image else { return }
            let newImage = current.flippedHorizontallySafe()

            let zoom = scrollView.zoomScale
            let offset = scrollView.contentOffset
            let inset = scrollView.contentInset

            let anim: UIView.AnimationOptions = .transitionFlipFromLeft
            if animated {
                UIView.transition(with: imageView, duration: 0.5, options: [anim, .showHideTransitionViews]) {
                    self.imageView.image = newImage
                } completion: { _ in
                    self.originalImage = newImage
                    // Giữ nguyên trạng thái zoom/offset
                    self.scrollView.setZoomScale(zoom, animated: false)
                    self.scrollView.contentOffset = offset
                    self.scrollView.contentInset = inset
                }
            } else {
                imageView.image = newImage
                originalImage = newImage
            }
        }

        /// Lật dọc với animation (đã fix orientation)
        func flipVertical(animated: Bool = true) {
            guard let current = imageView.image else { return }
            let newImage = current.flippedVerticallySafe()

            let zoom = scrollView.zoomScale
            let offset = scrollView.contentOffset
            let inset = scrollView.contentInset

            let anim: UIView.AnimationOptions = .transitionFlipFromTop
            if animated {
                UIView.transition(with: imageView, duration: 0.5, options: [anim, .showHideTransitionViews]) {
                    self.imageView.image = newImage
                } completion: { _ in
                    self.originalImage = newImage
                    self.scrollView.setZoomScale(zoom, animated: false)
                    self.scrollView.contentOffset = offset
                    self.scrollView.contentInset = inset
                }
            } else {
                imageView.image = newImage
                originalImage = newImage
            }
        }
    // MARK: - Layout logic
    private func layoutForImage() {
        guard let img = originalImage, bounds.width > 0 && bounds.height > 0 else { return }

        let viewW = scrollView.bounds.width
        let viewH = scrollView.bounds.height

        let imgW = img.size.width
        let imgH = img.size.height

        let widthRatio = viewW / imgW
        let heightRatio = viewH / imgH
        let scale = min(widthRatio, heightRatio)

        let dispW = imgW * scale
        let dispH = imgH * scale

        imageView.transform = .identity
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: dispW, height: dispH))

        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.setZoomScale(1.0, animated: false)

        centerContent()
        updateZoomState()
    }

    // Trung tâm hoá nội dung
    private func centerContent() {
        let scrollBounds = scrollView.bounds
        let contentSize = scrollView.contentSize

        let insetX = max((scrollBounds.width - contentSize.width) / 2, 0)
        let insetY = max((scrollBounds.height - contentSize.height) / 2, 0)

        scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }

    private func updateZoomState() {
        scrollView.isScrollEnabled = isZoomEnabled
        scrollView.pinchGestureRecognizer?.isEnabled = isZoomEnabled

        if !isZoomEnabled {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension RotatableZoomImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isZoomEnabled ? imageView : nil
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
}

