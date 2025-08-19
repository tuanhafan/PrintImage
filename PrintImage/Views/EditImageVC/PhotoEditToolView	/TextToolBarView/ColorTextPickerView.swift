//
//  ColorPickerView.swift
//  PrintImage
//
//  Created by Alex Tran on 18/8/25.
//

import Foundation
import UIKit
import UIKit

// MARK: - Color Wheel (vẽ vòng tròn đủ màu)
import UIKit

class ColorTextPickerView: UIView {
    
    private let colorWheelView = ColorWheelView()
    private let colorSlider = GradientSlider(type: .color)
    private let alphaSlider = GradientSlider(type: .alpha)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        colorWheelView.translatesAutoresizingMaskIntoConstraints = false
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        alphaSlider.translatesAutoresizingMaskIntoConstraints = false
        
        
//        colorSlider.transform = CGAffineTransform(rotationAngle: -.pi/2)
//        alphaSlider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        
        addSubview(colorWheelView)
        addSubview(colorSlider)
        addSubview(alphaSlider)
        NSLayoutConstraint.activate([
            colorWheelView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            colorWheelView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            
            
            colorSlider.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7), // dài
               colorSlider.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7), // dày
               colorSlider.leadingAnchor.constraint(equalTo: colorWheelView.trailingAnchor, constant: 10),
               colorSlider.centerYAnchor.constraint(equalTo: colorWheelView.centerYAnchor),

               alphaSlider.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
               alphaSlider.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
               alphaSlider.leadingAnchor.constraint(equalTo: colorSlider.trailingAnchor, constant: 5),
               alphaSlider.centerYAnchor.constraint(equalTo: colorWheelView.centerYAnchor),
        ])
    }
}
