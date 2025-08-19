//
//  EditableView.swift
//  PrintImage
//
//  Created by Alex Tran on 16/8/25.
//

import Foundation
import UIKit


final class StickerEditableView: UIView {
    private let contentImageView = UIImageView()
    private let deleteButton = UIButton(type: .custom)
    private let resizeButton = UIButton(type: .custom)
    private let borderBackground = UIView()
    
    // Trạng thái cho resize/rotate
    private var initialTransform: CGAffineTransform = .identity
    private var initialDistance: CGFloat = 0
    private var initialAngle: CGFloat = 0
    private var initialCenter: CGPoint = .zero
    private var initialBBoxSize: CGSize = .zero   // kích thước bbox sau transform tại thời điểm bắt đầu gesture
    private let minSide: CGFloat = 35             // kích thước nhỏ nhất (theo bbox)
    
    init(frame: CGRect, imageIndex: Int) {
        let scaledFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.width * 0.5,
            height: frame.height * 0.5
        )
        super.init(frame: scaledFrame)
        
        borderBackground.layer.borderColor = UIColor.black.cgColor
        borderBackground.layer.borderWidth = 1
        borderBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderBackground)
        sendSubviewToBack(borderBackground)
        NSLayoutConstraint.activate([
            borderBackground.topAnchor.constraint(equalTo: topAnchor),
            borderBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        isUserInteractionEnabled = true
        
        // UIImageView thay cho UILabel
        if let img = UIImage(named: "\(imageIndex)") {
            contentImageView.image = img
        }
        contentImageView.contentMode = .scaleAspectFit
        addSubview(contentImageView)
        
        // Delete button
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding = 0
        deleteButton.configuration = config
        
        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let palette = UIImage.SymbolConfiguration(paletteColors: [.white, .lightGray])
        let finalConfig = sizeConfig.applying(palette)
        if let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: finalConfig) {
            deleteButton.setImage(image, for: .normal)
        }
        deleteButton.frame = CGRect(x: -10, y: -10, width: 20, height: 20)
        deleteButton.addTarget(self, action: #selector(deleteSelf), for: .touchUpInside)
        addSubview(deleteButton)
        
        // Resize button
        let imageresizeButton = UIImage(systemName: "record.circle", withConfiguration: sizeConfig)
        resizeButton.setImage(imageresizeButton, for: .normal)
        resizeButton.tintColor = .white
        resizeButton.frame = CGRect(x: frame.width - 15, y: frame.height - 15, width: 40, height: 40)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(resizeAndRotate(_:)))
        resizeButton.addGestureRecognizer(pan)
        addSubview(resizeButton)
        
        // Pan để di chuyển
        let movePan = UIPanGestureRecognizer(target: self, action: #selector(moveView(_:)))
        addGestureRecognizer(movePan)
        
        // Tap bring to front
        let tap = UITapGestureRecognizer(target: self, action: #selector(bringToFront))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentImageView.frame = bounds.insetBy(dx: 4, dy: 4)
        resizeButton.frame = CGRect(x: bounds.width - 20, y: bounds.height - 20, width: 30, height: 30)
    }
    
    // MARK: - Actions
    @objc private func deleteSelf() {
        removeFromSuperview()
    }
    
    @objc private func moveView(_ recognizer: UIPanGestureRecognizer) {
        guard let spv = superview else { return }
        if recognizer.state == .began {
            spv.bringSubviewToFront(self)
        }
        let t = recognizer.translation(in: spv)
        center = CGPoint(x: center.x + t.x, y: center.y + t.y)
        recognizer.setTranslation(.zero, in: spv)
        
        let bbox = transformedBoundingSize()
        let halfW = bbox.width / 2
        let halfH = bbox.height / 2
        var newCenter = center
        newCenter.x = max(halfW, min(spv.bounds.width - halfW, newCenter.x))
        newCenter.y = max(halfH, min(spv.bounds.height - halfH, newCenter.y))
        center = newCenter
    }
    
    @objc private func resizeAndRotate(_ recognizer: UIPanGestureRecognizer) {
        guard let spv = superview else { return }
        if recognizer.state == .began {
            spv.bringSubviewToFront(self)
        }
        let location = recognizer.location(in: spv)
        let v = CGPoint(x: location.x - center.x, y: location.y - center.y)
        let distance = hypot(v.x, v.y)
        let angle = atan2(v.y, v.x)
        
        switch recognizer.state {
        case .began:
            initialTransform = transform
            initialCenter = center
            initialDistance = max(distance, 0.0001)
            initialAngle = angle
            initialBBoxSize = bounds.applying(initialTransform).size
        case .changed:
            guard initialDistance > 0 else { return }
            var scale = distance / initialDistance
            let minScaleW = minSide / max(initialBBoxSize.width, 0.0001)
            let minScaleH = minSide / max(initialBBoxSize.height, 0.0001)
            let minScale = max(minScaleW, minScaleH)
            if scale < minScale { scale = minScale }
            let angleDiff = angle - initialAngle
            transform = initialTransform.rotated(by: angleDiff).scaledBy(x: scale, y: scale)
        default:
            break
        }
    }
    
    @objc private func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    // MARK: - Helpers
    private func transformedBoundingSize() -> CGSize {
        let rect = bounds.applying(transform)
        return CGSize(width: abs(rect.width), height: abs(rect.height))
    }
    
    func removeSubview(){
        deleteButton.isHidden = true
        resizeButton.isHidden = true
        borderBackground.isHidden = true
    }
}
