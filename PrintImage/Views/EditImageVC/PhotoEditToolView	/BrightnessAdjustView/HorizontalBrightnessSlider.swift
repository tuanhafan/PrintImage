//
//  HorizontalBrightnessSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 11/8/25.
//

import UIKit

class HorizontalBrightnessSlider: UIControl {
        private let trackView = UIView()
        private let fillView = UIView()
        private let knobView = UIImageView()
        private let context = CIContext()
        var originalImage: UIImage?
        var onBrightnessChanged: ((CGFloat) -> Void)?
    
        var value: CGFloat = 0.5 {
            didSet {
                value = min(max(value, 0), 1) // clamp 0...1
                setNeedsLayout()
                sendActions(for: .valueChanged)
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            // cho phép knob hiển thị ngoài bounds nếu cần
            clipsToBounds = false

            // Track
            trackView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            trackView.layer.cornerRadius = 8
            // KHÔNG để subview ăn touch -> cho phép touch truyền về control
            trackView.isUserInteractionEnabled = false
            addSubview(trackView)

            // Fill
            fillView.backgroundColor = UIColor.systemBlue
            fillView.layer.cornerRadius = 8
            fillView.isUserInteractionEnabled = false
            trackView.addSubview(fillView)

            // Knob
            knobView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
            knobView.layer.cornerRadius = 15
            knobView.layer.borderWidth = 1
            knobView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            knobView.contentMode = .center
            // hiển thị icon
            knobView.image = UIImage(systemName: "circle.lefthalf.filled")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            // KHÔNG để knobView ăn touch
            knobView.isUserInteractionEnabled = false
            addSubview(knobView)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            let trackHeight: CGFloat = 8
            trackView.frame = CGRect(
                x: 0,
                y: (bounds.height - trackHeight) / 2,
                width: bounds.width,
                height: trackHeight
            )

            let fillWidth = bounds.width * value
            fillView.frame = CGRect(
                x: 0,
                y: 0,
                width: fillWidth,
                height: trackView.bounds.height
            )

            let knobSize: CGFloat = 30
            // giữ knob ở trong (nhưng knob có thể vươn ra 1 phần nếu bạn muốn)
            let knobCenterX = bounds.width * value
            knobView.frame = CGRect(
                x: knobCenterX - knobSize / 2,
                y: (bounds.height - knobSize) / 2,
                width: knobSize,
                height: knobSize
            )
        }

        // Mở rộng vùng nhận touch để bao cả phần knob vươn ra ngoài bounds
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            // nếu nằm trong bounds thì ok
            if bounds.contains(point) { return true }

            // kiểm tra xem có nằm trong vùng knob (mở rộng thêm 10px buffer)
            let knobHitFrame = knobView.frame.insetBy(dx: -10, dy: -10)
            if knobHitFrame.contains(point) { return true }

            return false
        }

        // Touch handling
        override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            updateValue(with: touch)
            return true
        }

        override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            updateValue(with: touch)
            return true
        }

        private func updateValue(with touch: UITouch) {
            let location = touch.location(in: self)
            let newValue = location.x / bounds.width
            value = min(max(newValue, 0), 1)
            onBrightnessChanged?(value) // gửi value
        }
    
}
