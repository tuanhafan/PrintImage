//
//  ColorSpectrumView.swift
//  PrintImage
//
//  Created by Alex Tran on 7/8/25.
//

import UIKit

class ColorSpectrumView: UIView {

    private let imageView = UIImageView()
    private let colorCircle = UIView()
    private var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var onColorPicked: ((UIColor) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        addGesture()
    }

    func setImage(named imageName: String) {
        self.image = UIImage(named: imageName)
    }

    private func setupUI() {
        
        image = UIImage(named: "hexcolors")
        
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        colorCircle.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        colorCircle.backgroundColor = .clear
        colorCircle.layer.borderColor = UIColor.white.cgColor
        colorCircle.layer.borderWidth = 2
        colorCircle.layer.cornerRadius = 15
        colorCircle.layer.masksToBounds = true
        colorCircle.isUserInteractionEnabled = false
        colorCircle.layer.shadowColor = UIColor.black.cgColor
        colorCircle.layer.shadowOpacity = 0.3
        colorCircle.layer.shadowOffset = CGSize(width: 0, height: 2)
        colorCircle.layer.shadowRadius = 4
        colorCircle.layer.masksToBounds = false
        addSubview(colorCircle)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        var location = gesture.location(in: self)
            
            // Bán kính con trỏ
            let radius = colorCircle.frame.width / 2

            // Giới hạn location trong phạm vi ảnh, trừ ra nửa con trỏ
            location.x = max(radius, min(bounds.width - radius, location.x))
            location.y = max(radius, min(bounds.height - radius, location.y))

            // Cập nhật vị trí con trỏ
            colorCircle.center = location

            guard let image = image else { return }

            // Lấy màu từ ảnh
            let pickedColor = getPixelColor(at: location, in: imageView, image: image)
            colorCircle.backgroundColor = pickedColor

            onColorPicked?(pickedColor)
    }

    private func getPixelColor(at point: CGPoint, in imageView: UIImageView, image: UIImage) -> UIColor {
        guard let cgImage = image.cgImage else { return .clear }

        let size = imageView.bounds.size
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        let scaleX = imageSize.width / size.width
        let scaleY = imageSize.height / size.height
        let pixelPoint = CGPoint(x: point.x * scaleX, y: point.y * scaleY)

        guard let pixelData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else {
            return .clear
        }

        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow
        let x = Int(pixelPoint.x)
        let y = Int(pixelPoint.y)

        guard x >= 0, x < Int(imageSize.width), y >= 0, y < Int(imageSize.height) else { return .clear }

        let pixelIndex = y * bytesPerRow + x * bytesPerPixel
        let r = CGFloat(data[pixelIndex]) / 255.0
        let g = CGFloat(data[pixelIndex + 1]) / 255.0
        let b = CGFloat(data[pixelIndex + 2]) / 255.0
        let a = CGFloat(data[pixelIndex + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

