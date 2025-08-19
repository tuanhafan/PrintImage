//
//  DrawingToolView.swift
//  PrintImage
//
//  Created by Alex Tran on 14/8/25.
//

import Foundation
import UIKit



class DrawingDeleteColorView: UIView {
    
    private let sizeSlider = BrushSizeSlider()
    private let brushpreview = BrushDeletePreviewView()
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
        
        sizeSlider.translatesAutoresizingMaskIntoConstraints = false
        brushpreview.translatesAutoresizingMaskIntoConstraints = false
        sizeSlider.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        addSubview(sizeSlider)
        addSubview(brushpreview)
        
        NSLayoutConstraint.activate([
            sizeSlider.topAnchor.constraint(equalTo: topAnchor,constant: 10),
            sizeSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            sizeSlider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            brushpreview.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            brushpreview.leadingAnchor.constraint(equalTo: sizeSlider.trailingAnchor, constant: 20),
            brushpreview.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            brushpreview.widthAnchor.constraint(equalTo: brushpreview.heightAnchor),
        ])
        
        
        brushpreview.toggleIsErasing = { [weak self] in
            self?.iseraserEnable?()
        }
        brushpreview.toggleIsErasing = { [weak self] in
            self?.iseraserEnable?()
        }
    }
    

    
    @objc func sizeChanged(_ sender: UISlider) {
        let newSize = CGFloat(sizeSlider.value)
        brushpreview.size = CGFloat(newSize * 100)
        onSizeChanged?(newSize*100)
    }
    
}
