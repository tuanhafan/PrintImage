//
//  ZoomableImageView.swift
//  PrintImage
//
//  Created by Alex Tran on 2/8/25.
//

import Foundation
import UIKit
class ZoomableImageView: UIView, UIScrollViewDelegate {
    
    
    private let gridView = UIView()
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let containerView = UIView()
    private var currentRotation: CGFloat = 0
    private var currentImage = UIImage()
    var passRotate: ((_ rotate: CGAffineTransform) -> Void)?
    private var isGridVisible = false {
        didSet {
            gridView.isHidden = isGridVisible
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawGridOverlay()
    }
    
    // setup
    
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
        
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = true
        containerView.backgroundColor = .clear
        scrollView.addSubview(containerView)
        containerView.addSubview(imageView)
        
        // grid view
        
        gridView.backgroundColor = .clear
        gridView.isUserInteractionEnabled = false
        gridView.isHidden = true
        addSubview(gridView)
        gridView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridView.topAnchor.constraint(equalTo: topAnchor),
            gridView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        drawGridOverlay()
    }
    
    
    
    func setImage(_ image: UIImage,sizeImage: CGSize) {
        imageView.image = image
        
        scrollView.setZoomScale(1.0, animated: false)
        scrollView.contentInset = .zero
        scrollView.contentOffset = .zero
        imageView.transform = .identity
        
        currentImage = image
        let viewScale: CGFloat = 2
        
        let containerSize = CGSize(width: image.size.width * viewScale,
                                   height: image.size.height * viewScale)
        
        // Set frame containerView
        containerView.frame = CGRect(origin: .zero, size: containerSize)
        
        // Tính offset trước khi set frame mới cho imageView
        let offsetX = (containerSize.width - scrollView.bounds.width) / 2
        let offsetY = (containerSize.height - scrollView.bounds.height) / 2
        
        // Gán contentSize trước để scrollView không tự điều chỉnh lại offset
        scrollView.contentSize = containerSize
        
        // Set lại frame cho imageView
        imageView.frame = CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: sizeImage)
        
        // Gán offset cuối cùng
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    private func centerContainerView() {
        let offsetX = max((scrollView.bounds.width - containerView.frame.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - containerView.frame.height) / 2, 0)
        containerView.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        containerView.frame.origin = CGPoint(x: offsetX, y: offsetY)
    }
    
    // Action
    
    func setGridVisible(_ visible: Bool) {
        isGridVisible = visible
    }
    
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    func rotateImageView(by angle: CGFloat) {
        containerView.transform = containerView.transform.rotated(by: angle)
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
    
    func renderViewToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        let image = renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
        return image
    }
    
    private func drawGridOverlay() {
        let numberOfLines = 2 // chia 3 phần
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        
        // Đường dọc
        for i in 1...numberOfLines {
            let x = CGFloat(i) * width / CGFloat(numberOfLines + 1)
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: height))
        }
        
        // Đường ngang
        for i in 1...numberOfLines {
            let y = CGFloat(i) * height / CGFloat(numberOfLines + 1)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = nil
        
        gridView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // clear cũ
        gridView.layer.addSublayer(shapeLayer)
    }
    
    func rotateImageBy90Degrees() {
        imageView.transform = imageView.transform.rotated(by: .pi / 2)
        passRotate?(imageView.transform)
    }
    
    
    func rotateImageBy90Ingrees() {
        imageView.transform = imageView.transform.rotated(by: -(.pi / 2))
        passRotate?(imageView.transform)
    }
    
    
}
