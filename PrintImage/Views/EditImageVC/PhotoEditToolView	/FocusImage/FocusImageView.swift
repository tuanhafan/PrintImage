//
//  FocusImageView.swift
//  PrintImage
//
//  Created by Alex Tran on 14/8/25.
//

import Foundation
import UIKit


class FocusImageView: UIView {
        
        private let originalImageView = UIImageView()
        private let blurImageView = UIImageView()
        private let maskLayer = CAShapeLayer()
        private let borderLayer = CAShapeLayer() // viền trắng
        
        private var circleCenter: CGPoint
        private var circleRadius: CGFloat
        
        private var lastPanPoint: CGPoint = .zero
        private var lastScale: CGFloat = 1.0
        
        var isSpotlightEnabled: Bool = true {
            didSet { updateMask() }
        }
        
        // Giới hạn zoom
        var minRadius: CGFloat = 50
        var maxRadius: CGFloat = 200
        
        init(frame: CGRect, image: UIImage, initialRadius: CGFloat = 80) {
            self.circleCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
            self.circleRadius = initialRadius
            super.init(frame: frame)
            
            // Ảnh gốc
            originalImageView.image = image
            originalImageView.contentMode = .scaleAspectFit
            originalImageView.frame = bounds
            addSubview(originalImageView)
            
            // Ảnh blur
            blurImageView.image = applyBlur(to: image)
            blurImageView.contentMode = .scaleAspectFit
            blurImageView.frame = bounds
            addSubview(blurImageView)
            
            // Mask cho blur
            maskLayer.frame = bounds
            blurImageView.layer.mask = maskLayer
            
            // Viền trắng
            borderLayer.strokeColor = UIColor.white.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.lineWidth = 3
            layer.addSublayer(borderLayer)
            
            updateMask()
            
            // Gesture
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            addGestureRecognizer(pan)
            addGestureRecognizer(pinch)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func applyBlur(to image: UIImage) -> UIImage {
            let ciImage = CIImage(image: image)!
            let blurFilter = CIFilter(name: "CIGaussianBlur")!
            blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
            blurFilter.setValue(12.0, forKey: kCIInputRadiusKey)
            
            let context = CIContext()
            guard let output = blurFilter.outputImage else { return image }
            
            let cropped = output.cropped(to: ciImage.extent)
            guard let cgImage = context.createCGImage(cropped, from: cropped.extent) else {
                return image
            }
            
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        private func updateMask() {
            if !isSpotlightEnabled {
                maskLayer.path = nil
                borderLayer.path = nil
                return
            }
            
            let path = UIBezierPath(rect: bounds)
            let circleRect = CGRect(
                x: circleCenter.x - circleRadius,
                y: circleCenter.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
            let circlePath = UIBezierPath(ovalIn: circleRect)
            
            // Mask
            path.append(circlePath)
            maskLayer.fillRule = .evenOdd
            maskLayer.path = path.cgPath
            
            // Viền trắng
            borderLayer.path = circlePath.cgPath
        }
        
        private func clampCenter() {
            let imageFrame = imageDisplayedFrame()
            
            let minX = imageFrame.minX - circleRadius / 2
            let maxX = imageFrame.maxX + circleRadius / 2
            let minY = imageFrame.minY - circleRadius / 2
            let maxY = imageFrame.maxY + circleRadius / 2
            
            circleCenter.x = max(minX, min(maxX, circleCenter.x))
            circleCenter.y = max(minY, min(maxY, circleCenter.y))
        }
        
        private func imageDisplayedFrame() -> CGRect {
            guard let image = originalImageView.image else { return bounds }
            let imageRatio = image.size.width / image.size.height
            let viewRatio = bounds.width / bounds.height
            
            if imageRatio > viewRatio {
                let scale = bounds.width / image.size.width
                let height = image.size.height * scale
                let y = (bounds.height - height) / 2
                return CGRect(x: 0, y: y, width: bounds.width, height: height)
            } else {
                let scale = bounds.height / image.size.height
                let width = image.size.width * scale
                let x = (bounds.width - width) / 2
                return CGRect(x: x, y: 0, width: width, height: bounds.height)
            }
        }
        
        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard isSpotlightEnabled else { return }
            let translation = gesture.translation(in: self)
            if gesture.state == .began {
                lastPanPoint = circleCenter
            }
            circleCenter = CGPoint(
                x: lastPanPoint.x + translation.x,
                y: lastPanPoint.y + translation.y
            )
            clampCenter()
            updateMask()
        }
        
        @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard isSpotlightEnabled else { return }
            if gesture.state == .began {
                lastScale = 1.0
            }
            let scale = 1.0 + (gesture.scale - lastScale)
            circleRadius = max(minRadius, min(maxRadius, circleRadius * scale))
            lastScale = gesture.scale
            
            clampCenter()
            updateMask()
        }
    }

