//
//  ColorWheelView.swift
//  PrintImage
//
//  Created by Alex Tran on 18/8/25.
//

import Foundation
import UIKit

class ColorWheelView: UIView {
    
    // MARK: - Public
    var onColorChanged: ((UIColor) -> Void)?
    
    var selectedColor: UIColor = .white {
        didSet {
            updatePointerPosition(for: selectedColor)
            onColorChanged?(selectedColor)
        }
    }
    
    // MARK: - Private
    private let pointerView = UIView()
    private var radius: CGFloat { return bounds.width / 2 }
    private var wheelCenter: CGPoint { return CGPoint(x: bounds.midX, y: bounds.midY) }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        // Pointer setup
        pointerView.frame.size = CGSize(width: 20, height: 20)
        pointerView.layer.cornerRadius = 10
        pointerView.layer.borderColor = UIColor.white.cgColor
        pointerView.layer.borderWidth = 1
        pointerView.backgroundColor = .clear
        addSubview(pointerView)
        
        // Pan gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        // Vẽ vòng tròn gradient (color wheel)
        let radius = rect.width / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        for angle in stride(from: 0, to: 360, by: 1) {
            let startAngle = CGFloat(angle) * .pi / 180
            let endAngle = CGFloat(angle + 1) * .pi / 180
            
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            path.addLine(to: center)
            path.close()
            
            UIColor(hue: CGFloat(angle) / 360.0, saturation: 1, brightness: 1, alpha: 1).setFill()
            path.fill()
        }
        
        // Vẽ overlay làm mờ dần vào tâm (giảm saturation)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
        ctx.drawRadialGradient(gradient,
                               startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: radius,
                               options: .drawsBeforeStartLocation)
    }
    
    // MARK: - Touch & Pan
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let dx = location.x - wheelCenter.x
        let dy = location.y - wheelCenter.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // Giới hạn con trỏ không vượt quá (radius + pointerView.width/2)
        let maxDist = radius
        let clampedDist = min(distance, maxDist)
        
        let angle = atan2(dy, dx)
        let newX = wheelCenter.x + cos(angle) * clampedDist
        let newY = wheelCenter.y + sin(angle) * clampedDist
        
        pointerView.center = CGPoint(x: newX, y: newY)
        
        let hue = (angle < 0 ? angle + 2 * .pi : angle) / (2 * .pi)
        let sat = clampedDist / radius
        selectedColor = UIColor(hue: hue, saturation: sat, brightness: 1, alpha: 1)
        onColorChanged?(selectedColor)
    }
    
    // MARK: - Update pointer theo màu
    private func updatePointerPosition(for color: UIColor) {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        let angle = hue * 2 * .pi
        let dist = sat * radius
        
        let newX = wheelCenter.x + cos(angle) * dist
        let newY = wheelCenter.y + sin(angle) * dist
        
        pointerView.center = CGPoint(x: newX, y: newY)
    }
}
