//
//  DrawingToolView.swift
//  PrintImage
//
//  Created by Alex Tran on 14/8/25.
//

import Foundation
import UIKit




import UIKit

class DrawingToolView: UIView {
    
    private let colorSlider = ColorPickerSlider()
    private let sizeSlider = BrushSizeSlider()
    private let brushpreview = BrushPreviewView()
    var onColorSlieChanged: ((UIColor) -> Void)?
    var onSizeChanged: ((CGFloat) -> Void)?
    var iseraserEnable: (() -> Void)?
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
        
        // StackView chứa 2 slider
        let stackView = UIStackView(arrangedSubviews: [colorSlider, sizeSlider])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        sizeSlider.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        
        addSubview(stackView)
        addSubview(brushpreview)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor,constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: heightAnchor,multiplier: 0.6),
            
            brushpreview.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            brushpreview.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 20),
            brushpreview.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            brushpreview.widthAnchor.constraint(equalTo: brushpreview.heightAnchor),
        ])
        
        colorSlider.onColorChanged = { [weak brushpreview] newColor in
            brushpreview?.color = newColor
            self.onColorSlieChanged?(newColor)
        }
        
        brushpreview.toggleIsErasing = { [weak self] in
            self?.iseraserEnable?()
        }
    }
    
    // Hàm public để lấy giá trị
    func getSelectedColor() -> UIColor {
        return colorSlider.colorForValue(colorSlider.value) // cần để colorForValue là internal hoặc public
    }
    
    func getBrushSize() -> Float {
        return sizeSlider.value
    }

    
    @objc func sizeChanged(_ sender: UISlider) {
        let newSize = CGFloat(sizeSlider.value)
        brushpreview.size = CGFloat(newSize * 100)
        onSizeChanged?(newSize*100)
    }
    
}
