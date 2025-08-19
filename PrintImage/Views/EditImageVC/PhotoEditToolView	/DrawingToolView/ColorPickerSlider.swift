//
//  BrushSizeSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 15/8/25.
//

import Foundation
import UIKit

class ColorPickerSlider: UISlider {
    
    var onColorChanged: ((UIColor) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Tạo ảnh gradient cho track
        let gradientImage = createGradientImage(size: CGSize(width: 300, height: 5))
        setMinimumTrackImage(gradientImage, for: .normal)
        setMaximumTrackImage(gradientImage, for: .normal)
        
        // Thumb mặc định
        updateThumbColor()
        
        minimumValue = 0
        maximumValue = 1
        value = 0
        
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    private func createGradientImage(size: CGSize) -> UIImage {
        let colors: [UIColor] = [
            .black,
            .white,
            .red,
            .yellow,
            .green,
            .blue
        ]
        
        let gradientLayer = CAGradientLayer()
           gradientLayer.frame = CGRect(origin: .zero, size: size)
           gradientLayer.colors = colors.map { $0.cgColor }
           gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
           gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

           UIGraphicsBeginImageContextWithOptions(size, true, 0) // 👈 true = không transparent
           gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
           let image = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return image!.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }
    
    private func createThumbImage(color: UIColor, size: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(color.cgColor)
        ctx.addEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        ctx.fillPath()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    func colorForValue(_ value: Float) -> UIColor {
        // Lấy màu từ gradient dựa theo value
        let colors: [UIColor] = [.black, .white, .red, .yellow, .green, .blue]
        let step = 1.0 / Float(colors.count - 1)
        let index = min(Int(value / step), colors.count - 2)
        let t = (value - Float(index) * step) / step
        
        return blend(color1: colors[index], color2: colors[index+1], t: CGFloat(t))
    }
    
    private func blend(color1: UIColor, color2: UIColor, t: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: r1 + (r2 - r1) * t,
                       green: g1 + (g2 - g1) * t,
                       blue: b1 + (b2 - b1) * t,
                       alpha: 1)
    }
    
    @objc private func sliderValueChanged() {
        updateThumbColor()
        let newColor = colorForValue(value)
        onColorChanged?(newColor)
    }
    
    private func updateThumbColor() {
        let color = colorForValue(value)
        setThumbImage(createThumbImage(color: color, size: 28), for: .normal)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: bounds.origin.x, y: bounds.midY - 10, width: bounds.width, height: 5)
    }
}
