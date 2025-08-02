//
//  ZoomableImageView.swift
//  PrintImage
//
//  Created by Alex Tran on 2/8/25.
//

import Foundation
import UIKit
class ZoomableImageView: UIView, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let containerView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // self là wrapperView (khung trắng)
        backgroundColor = .white
        clipsToBounds = true  // Cắt phần ảnh tràn ra ngoài
        // Setup scrollView
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.5
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = false
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.decelerationRate = .init(rawValue: 0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Setup imageView
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.addSubview(containerView)
        containerView.addSubview(imageView)
    }
    
    
    
    func setImage(_ image: UIImage) {
        imageView.image = image
        
        let imageScale: CGFloat = 0.1
        let viewScale: CGFloat = 0.5
        
        let imageSize = CGSize(width: image.size.width * imageScale,
                               height: image.size.height * imageScale)
        
        let containerSize = CGSize(width: image.size.width * viewScale ,
                                   height: image.size.height * viewScale)
        
        // Set frame containerView và imageView
        containerView.frame = CGRect(origin: .zero, size: containerSize)
        let offsetX = (containerSize.width - scrollView.bounds.width)/2
        let offsetY = (containerSize.height - scrollView.bounds.height)/2
        imageView.frame = CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: imageSize)
        // Set contentSize của scrollView đúng theo container
       
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
        scrollView.contentSize = containerView.frame.size
    }
    
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
    }
    
    func cropVisibleImage() -> UIImage? {
        guard let image = imageView.image else { return nil }
        
        let scale = image.scale
        let zoomScale = scrollView.zoomScale
        
        // Kích thước của ảnh thực (tính theo tỷ lệ zoom)
        let visibleRect = CGRect(
            x: scrollView.contentOffset.x / zoomScale,
            y: scrollView.contentOffset.y / zoomScale,
            width: scrollView.bounds.width / zoomScale,
            height: scrollView.bounds.height / zoomScale
        )
        
        // Chuyển đổi sang hệ tọa độ ảnh thật
        let imageSize = image.size
        let factorX = imageSize.width / imageView.bounds.width
        let factorY = imageSize.height / imageView.bounds.height
        
        let cropRect = CGRect(
            x: visibleRect.origin.x * factorX,
            y: visibleRect.origin.y * factorY,
            width: visibleRect.size.width * factorX,
            height: visibleRect.size.height * factorY
        )
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
    }
    
}
