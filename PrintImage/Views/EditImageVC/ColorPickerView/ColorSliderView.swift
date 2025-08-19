//
//  ColorSliderView.swift
//  PrintImage
//
//  Created by Alex Tran on 8/8/25.
//

import UIKit

class ColorSliderView: UIView {

    private var thumbWidthRatio: CGFloat = 0.4
    private var thumbHeightRatio: CGFloat = 1.2
    var onColorChanged: ((String) -> Void)?

    var baseHexColor: String = "#FF00FF" {
        didSet {
                // Luôn chuẩn hóa về chữ in hoa để so sánh dễ hơn
                let upperHex = baseHexColor.uppercased()
                
                // Nếu không phải màu #000000 thì mới gán
                if upperHex != "#000000" {
                    baseColor = UIColor(hexString: baseHexColor) ?? UIColor.magenta
                    setNeedsDisplay()
                    
                    thumbView.backgroundColor = selectedColor().withAlphaComponent(0.8)
                }
            }
    }

     var selectedPosition: CGFloat = 0.0 {
        didSet {
            updateThumbPosition()
            thumbView.backgroundColor = selectedColor()
            let hex = selectedColor().toHexString()
            onColorChanged?(hex)
        }
    }
    private var baseColor: UIColor = UIColor.magenta

    private let thumbDiameter: CGFloat = 30.0
    private let thumbView = UIView()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupThumbView()
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupThumbView()
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Tính kích thước thumb dựa theo slider
        let thumbHeight = bounds.height * thumbHeightRatio
        let thumbWidth = bounds.height * thumbWidthRatio
        thumbView.bounds = CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight)
        thumbView.layer.cornerRadius = thumbWidth / 2

        updateThumbPosition()
    }
    
    private func setupThumbView() {
        
            thumbView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.8)
            thumbView.layer.borderColor = UIColor.white.cgColor
            thumbView.layer.borderWidth = 2
            thumbView.layer.shadowColor = UIColor.black.cgColor
            thumbView.layer.shadowOffset = CGSize(width: 0, height: 1)
            thumbView.layer.shadowOpacity = 0.5
            thumbView.layer.shadowRadius = 2
            selectedPosition = 0.0
            addSubview(thumbView)
    }

    private func updateThumbPosition() {
        let xPos = selectedPosition * (bounds.width - thumbView.bounds.width) + thumbView.bounds.width / 2
        let yPos = bounds.midY
        thumbView.center = CGPoint(x: xPos, y: yPos)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Draw horizontal gradient from baseColor to black
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [baseColor.cgColor, UIColor.black.cgColor] as CFArray
        let locations: [CGFloat] = [0, 1]

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
            let startPoint = CGPoint(x: 0, y: rect.midY)
            let endPoint = CGPoint(x: rect.maxX, y: rect.midY)
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
    }

    // MARK: - Touch Handling for dragging thumb

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSelectedPosition(with: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSelectedPosition(with: touches)
    }

    private func updateSelectedPosition(with touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Clamp x position inside bounds
        let clampedX = min(max(location.x, thumbDiameter / 2), bounds.width - thumbDiameter / 2)
        selectedPosition = (clampedX - thumbDiameter / 2) / (bounds.width - thumbDiameter)
    }

    // Public method to get the currently selected color
    func selectedColor() -> UIColor {
        return interpolateColor(from: baseColor, to: UIColor.black, fraction: selectedPosition)
    }

    // Helper to interpolate between two colors
    private func interpolateColor(from: UIColor, to: UIColor, fraction: CGFloat) -> UIColor {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0

        var tRed: CGFloat = 0
        var tGreen: CGFloat = 0
        var tBlue: CGFloat = 0
        var tAlpha: CGFloat = 0

        from.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        to.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)

        let red = fRed + (tRed - fRed) * fraction
        let green = fGreen + (tGreen - fGreen) * fraction
        let blue = fBlue + (tBlue - fBlue) * fraction
        let alpha = fAlpha + (tAlpha - fAlpha) * fraction

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}



