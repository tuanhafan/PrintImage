//
//  GradientSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 18/8/25.
//

import Foundation
import UIKit


class GradientSlider: UISlider {
    
    enum SliderType {
        case color   // hồng -> trắng
        case alpha   // hồng -> trong suốt (checkerboard)
    }
    
    private let sliderType: SliderType
    
    init(type: SliderType) {
        self.sliderType = type
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Xoay slider thành dọc
        self.transform = CGAffineTransform(rotationAngle: -.pi/2)
        self.minimumValue = 0
        self.maximumValue = 1
        
        let trackImage: UIImage
        switch sliderType {
        case .color:
            trackImage = Self.makeGradientImage(
                colors: [UIColor.magenta, UIColor.white],
                size: CGSize(width: 2, height: 8) // nhỏ thôi cũng được
            )
        case .alpha:
            trackImage = Self.makeAlphaGradientImage(
                baseColor: UIColor.magenta,
                size: CGSize(width: 2, height: 8) // nhỏ thôi cũng được
            )
        }
        
        let resizable = trackImage.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
        self.setMinimumTrackImage(resizable, for: .normal)
        self.setMaximumTrackImage(resizable, for: .normal)
        
        self.setThumbImage(makeThumb(), for: .normal)
    }
    
    /// AutoLayout hiểu đúng kích thước sau khi xoay
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.height, height: size.width)
    }
    
    private func makeThumb() -> UIImage {
        let size: CGFloat = 20
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.addEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        ctx.fillPath()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    // Gradient màu vẽ ngang
    private static func makeGradientImage(colors: [UIColor], size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        let cgColors = colors.map { $0.cgColor } as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: [0,1])!
        
        // Vẽ ngang
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: size.height/2),
                               end: CGPoint(x: size.width, y: size.height/2),
                               options: [])
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    // Gradient alpha vẽ ngang
    private static func makeAlphaGradientImage(baseColor: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        
        // Vẽ nền caro
        let cell: CGFloat = 10
        for y in stride(from: 0, to: size.height, by: cell) {
            for x in stride(from: 0, to: size.width, by: cell) {
                let isDark = (Int(x/cell) + Int(y/cell)) % 2 == 0
                ctx.setFillColor((isDark ? UIColor.lightGray : UIColor.white).cgColor)
                ctx.fill(CGRect(x: x, y: y, width: cell, height: cell))
            }
        }
        
        // Vẽ gradient ngang từ màu -> trong suốt
        let colors = [baseColor.withAlphaComponent(1).cgColor,
                      baseColor.withAlphaComponent(0).cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0,1])!
        
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: size.height/2),
                               end: CGPoint(x: size.width, y: size.height/2),
                               options: [])
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

