//
//  BrushSizeSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 15/8/25.
//

import Foundation
import UIKit


class BrushSizeSlider: UISlider {
        private let wedgeLayer = CAShapeLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }

        private func commonInit() {
            backgroundColor = .clear

            // Ẩn track mặc định để không bị tách làm 2 nửa
            setMinimumTrackImage(UIImage(), for: .normal)
            setMaximumTrackImage(UIImage(), for: .normal)

            // Thumb tròn trắng
            setThumbImage(makeThumb(diameter: 26, color: .white), for: .normal)

            // Layer hình nêm nằm dưới thumb
            wedgeLayer.fillColor = UIColor(white: 0.78, alpha: 1).cgColor
            wedgeLayer.shadowColor = UIColor.black.cgColor
            wedgeLayer.shadowOpacity = 0.18
            wedgeLayer.shadowRadius = 1.5
            wedgeLayer.shadowOffset = .zero
            layer.insertSublayer(wedgeLayer, at: 0)
        }

        // Tăng chiều cao khu vực track
        override func trackRect(forBounds bounds: CGRect) -> CGRect {
            let h: CGFloat = 18
            return CGRect(x: bounds.minX,
                          y: bounds.midY - h/2,
                          width: bounds.width,
                          height: h)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            let r = trackRect(forBounds: bounds)
            wedgeLayer.frame = bounds
            wedgeLayer.path = makeWedgePath(in: r, leftInset: 6).cgPath
        }

        // MARK: - Drawing

        private func makeWedgePath(in r: CGRect, leftInset: CGFloat) -> UIBezierPath {
            // Hình nêm: đầu trái nhọn, đầu phải bo tròn theo chiều cao
            let midY = r.midY
            let radius = r.height / 2
            let leftX = r.minX + leftInset
            let rightX = r.maxX

            let p = UIBezierPath()
            // Điểm nhọn bên trái
            p.move(to: CGPoint(x: leftX, y: midY))
            // Cạnh trên tới nửa tròn bên phải
            p.addLine(to: CGPoint(x: rightX - radius, y: r.minY))
            // Nửa tròn bên phải
            p.addArc(withCenter: CGPoint(x: rightX - radius, y: midY),
                     radius: radius,
                     startAngle: -.pi/2,
                     endAngle: .pi/2,
                     clockwise: true)
            // Cạnh dưới về lại mũi nhọn bên trái
            p.addLine(to: CGPoint(x: leftX, y: midY))
            p.close()
            return p
        }

        private func makeThumb(diameter: CGFloat, color: UIColor) -> UIImage {
            let size = CGSize(width: diameter, height: diameter)
            return UIGraphicsImageRenderer(size: size).image { ctx in
                ctx.cgContext.setShadow(offset: .zero, blur: 3,
                                        color: UIColor.black.withAlphaComponent(0.35).cgColor)
                ctx.cgContext.setFillColor(color.cgColor)
                ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            }
        }
    }
