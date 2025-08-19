//
//  BrushSizeSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 15/8/25.
//

import Foundation
import UIKit

final class BrushPreviewView: UIView {

    // Vòng ngoài và trong
    private let outerCircle = UIView()
    private let innerCircle = UIView()
    private let eraserImage = UIImageView()
    private var currentColor: UIColor = .black
    var toggleIsErasing: (() -> Void)?
    var iseraserEnable : Bool = false {
        didSet{
            if(iseraserEnable){
                outerCircle.backgroundColor = .lightGray.withAlphaComponent(0.6)
                innerCircle.backgroundColor = .lightGray.withAlphaComponent(1.0)
                eraserImage.isHidden = false
            } else {
                eraserImage.isHidden = true
                outerCircle.backgroundColor = currentColor.withAlphaComponent(0.6)
                innerCircle.backgroundColor = currentColor.withAlphaComponent(1.0)
            }
        }
    }
    var color: UIColor = .green {
        didSet {
            outerCircle.backgroundColor = color.withAlphaComponent(0.6)
            innerCircle.backgroundColor = color.withAlphaComponent(1.0)
            currentColor = color
        }
    }

    var size: CGFloat = 10 {
       
        didSet {
            updateInnerCircleScale()
        }
    }

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
        translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.isUserInteractionEnabled = true // Quan trọng, nếu không view sẽ không nhận touch
        self.addGestureRecognizer(tapGesture)
        
        
        outerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        eraserImage.translatesAutoresizingMaskIntoConstraints = false
        eraserImage.isHidden = true
        addSubview(outerCircle)
        addSubview(innerCircle)
        addSubview(eraserImage)

        NSLayoutConstraint.activate([
            outerCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            outerCircle.widthAnchor.constraint(equalTo: widthAnchor),
            outerCircle.heightAnchor.constraint(equalTo: heightAnchor),

            innerCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerCircle.widthAnchor.constraint(equalTo: widthAnchor),
            innerCircle.heightAnchor.constraint(equalTo: heightAnchor),
            
            eraserImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            eraserImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            eraserImage.widthAnchor.constraint(equalTo: widthAnchor),
            eraserImage.heightAnchor.constraint(equalTo: heightAnchor),
            
        ])
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        eraserImage.image = UIImage(systemName: "eraser.line.dashed", withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
        eraserImage.tintColor = .black
        eraserImage.contentMode = .center
        eraserImage.backgroundColor = .clear
        outerCircle.layer.cornerRadius = bounds.width / 2
        innerCircle.layer.cornerRadius = bounds.width / 2

        outerCircle.clipsToBounds = true
        innerCircle.clipsToBounds = true

        color = .black
        size = 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        outerCircle.layer.cornerRadius = outerCircle.bounds.width / 2
        innerCircle.layer.cornerRadius = innerCircle.bounds.width / 2
        eraserImage.layer.cornerRadius = eraserImage.bounds.width / 2
        updateInnerCircleScale()
    }

    private func updateInnerCircleScale() {
        // Size ở đây là tỷ lệ (ví dụ: 0.2 ~ 20% của vòng ngoài)
        let scale = max(0.1, min(size / 100.0, 1.0))
        innerCircle.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    @objc private func handleTap() {
        iseraserEnable = !iseraserEnable
        toggleIsErasing?()
    }
}
