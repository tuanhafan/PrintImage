//
//  EditableView.swift
//  PrintImage
//
//  Created by Alex Tran on 16/8/25.
//

import Foundation
import UIKit

final class EditableView: UIView {
    private let contentLabel = UILabel()
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
    
    init(frame: CGRect, emoji: String) {
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
        
        // Emoji label
        contentLabel.text = emoji
        contentLabel.font = UIFont.systemFont(ofSize: 60) // giữ cố định; phóng to/thu nhỏ bằng transform của cả view
        contentLabel.textAlignment = .center
        
        addSubview(contentLabel)
        
        // Delete button
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding = 0
        deleteButton.configuration = config
        
        // Config cho size + weight của SF Symbol
        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        
        // Config cho màu (palette)
        let palette = UIImage.SymbolConfiguration(paletteColors: [.white, .lightGray])
        
        // Gộp 2 config lại
        let finalConfig = sizeConfig.applying(palette)
        
        // Tạo image với config đã gộp
        if let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: finalConfig) {
            deleteButton.setImage(image, for: .normal)
        }
        
        // Frame button (hit area rộng 60x60, icon nhỏ bên trong)
        deleteButton.frame = CGRect(x: -10, y: -10, width: 20, height: 20)
        
        // Action
        deleteButton.addTarget(self, action: #selector(deleteSelf), for: .touchUpInside)
        
        // Add vào view
        addSubview(deleteButton)
        
        // Resize button (góc phải-dưới)
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
        
        // Tap để bring to front
        let tap = UITapGestureRecognizer(target: self, action: #selector(bringToFront))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.frame = bounds.insetBy(dx: 3, dy: 3)
        // Nút resize đặt ở góc phải-dưới trong hệ toạ độ local (nó sẽ xoay/scale theo view)
        resizeButton.frame = CGRect(x: bounds.width - 20, y: bounds.height - 20, width: 30, height: 30)
        // KHÔNG chỉnh lại font theo bounds ở đây, vì đã scale toàn bộ view bằng transform
        // contentLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.8) // bỏ
        let padding: CGFloat = 4
        contentLabel.frame = bounds.insetBy(dx: padding, dy: padding)
        
        // Lấy chiều cao khả dụng
        let availableHeight = contentLabel.bounds.height
        // Chọn fontSize = 90% chiều cao khả dụng
        let fontSize = availableHeight * 0.9
        contentLabel.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    // MARK: - Actions
    @objc private func deleteSelf() {
        removeFromSuperview()
    }
    
    // Di chuyển: chỉ đổi center; kẹp bằng center dựa trên bbox sau transform
    @objc private func moveView(_ recognizer: UIPanGestureRecognizer) {
        guard let spv = superview else { return }
        
        if recognizer.state == .began {
            spv.bringSubviewToFront(self)   // 👉 đưa lên trên khi bắt đầu kéo
        }
        
        let t = recognizer.translation(in: spv)
        center = CGPoint(x: center.x + t.x, y: center.y + t.y)
        recognizer.setTranslation(.zero, in: spv)
        
        // Kẹp trong superview theo bbox đã transform
        let bbox = transformedBoundingSize()
        let halfW = bbox.width / 2
        let halfH = bbox.height / 2
        var newCenter = center
        newCenter.x = max(halfW, min(spv.bounds.width - halfW, newCenter.x))
        newCenter.y = max(halfH, min(spv.bounds.height - halfH, newCenter.y))
        center = newCenter
        // LƯU Ý: Không gán trực tiếp frame.origin khi view đã transform → sẽ méo!
    }
    
    // Resize + Rotate theo toạ độ superview để đúng trực giác
    @objc private func resizeAndRotate(_ recognizer: UIPanGestureRecognizer) {
        guard let spv = superview else { return }
        if recognizer.state == .began {
                spv.bringSubviewToFront(self)   // 👉 đưa lên trên khi resize
            }
        let location = recognizer.location(in: spv)
        let v = CGPoint(x: location.x - center.x, y: location.y - center.y) // vector từ tâm đến điểm chạm (superview space)
        let distance = hypot(v.x, v.y)
        let angle = atan2(v.y, v.x)
        
        switch recognizer.state {
        case .began:
            initialTransform = transform
            initialCenter = center
            // Vector/độ dài ban đầu
            initialDistance = max(distance, 0.0001)
            initialAngle = angle
            // Kích thước bbox tại thời điểm bắt đầu (để tính min scale)
            initialBBoxSize = bounds.applying(initialTransform).size
            
        case .changed:
            guard initialDistance > 0 else { return }
            
            // Tính scale tương đối theo tỉ lệ thay đổi độ dài vector
            var scale = distance / initialDistance
            
            // Đảm bảo kích thước tối thiểu theo bbox
            let minScaleW = minSide / max(initialBBoxSize.width, 0.0001)
            let minScaleH = minSide / max(initialBBoxSize.height, 0.0001)
            let minScale = max(minScaleW, minScaleH)
            if scale < minScale { scale = minScale }
            
            // Góc xoay tương đối
            let angleDiff = angle - initialAngle
            
            // Áp transform dựa trên transform ban đầu (không ghi đè translate)
            // Scale đồng nhất → thứ tự rotate/scale không làm méo
            transform = initialTransform.rotated(by: angleDiff).scaledBy(x: scale, y: scale)
            
            // Không đổi center ở đây; di chuyển là gesture khác
        default:
            break
        }
    }
    
    @objc private func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    // MARK: - Helpers
    private func transformedBoundingSize() -> CGSize {
        // Lấy kích thước bbox của bounds sau khi áp transform hiện tại
        let rect = bounds.applying(transform)
        return CGSize(width: abs(rect.width), height: abs(rect.height))
    }
    
    func removeSubview(){
        deleteButton.isHidden = true
        resizeButton.isHidden = true
        borderBackground.isHidden = true
    }
}
