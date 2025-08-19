//
//  DrawingToolView.swift
//  PrintImage
//
//  Created by Alex Tran on 14/8/25.
//

import Foundation
import UIKit
import CoreImage


final class DrawingDeleteColorImageView: UIImageView {

       var brushSize: CGFloat = 1        // đổi cỡ bút
       var isErasing: Bool = false         // false = tô hiện màu, true = xóa nét màu

       private let grayImageView = UIImageView()
       private let maskLayer = CALayer()
       private var maskImage: UIImage?
       private var lastPoint: CGPoint?

       // baseImage: ảnh màu gốc (chính là ảnh đang hiển thị trong imageView của bạn)
       init(frame: CGRect, baseImage: UIImage, contentMode: UIView.ContentMode = .scaleAspectFit) {
           super.init(frame: frame)
           isUserInteractionEnabled = true

           // tạo ảnh đen trắng
           let gray = DrawingDeleteColorImageView.toGray(image: baseImage)

           // ảnh đen trắng phủ lên trên
           grayImageView.image = gray
           grayImageView.frame = bounds
           grayImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           grayImageView.contentMode = contentMode
           addSubview(grayImageView)

           // tạo mask trắng (hiện toàn bộ ảnh đen trắng)
           let size = grayImageView.bounds.size
           let scale = UIScreen.main.scale
           UIGraphicsBeginImageContextWithOptions(size, false, scale)
           UIColor.white.setFill()
           UIRectFill(CGRect(origin: .zero, size: size))
           maskImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()

           maskLayer.frame = grayImageView.bounds
           maskLayer.contentsGravity = .resize
           maskLayer.contentsScale = scale
           maskLayer.contents = maskImage?.cgImage
           grayImageView.layer.mask = maskLayer
       }

       required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           lastPoint = touches.first?.location(in: grayImageView)
       }

       override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           guard let p = touches.first?.location(in: grayImageView),
                 let last = lastPoint else { return }
           drawStroke(from: last, to: p)
           lastPoint = p
       }

       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           lastPoint = nil
       }

       private func drawStroke(from: CGPoint, to: CGPoint) {
           guard let currentMask = maskImage else { return }
           let size = grayImageView.bounds.size
           let scale = UIScreen.main.scale

           UIGraphicsBeginImageContextWithOptions(size, false, scale)
           currentMask.draw(in: CGRect(origin: .zero, size: size))

           if let ctx = UIGraphicsGetCurrentContext() {
               ctx.setLineCap(.round)
               ctx.setLineWidth(brushSize)
               if isErasing {
                   // đưa vùng đã lộ màu về lại đen trắng: vẽ TRẮNG (mask opaque)
                   ctx.setBlendMode(.normal)
                   ctx.setStrokeColor(UIColor.white.cgColor)
               } else {
                   // lộ màu gốc: xóa mask (alpha 0) ở nét vẽ
                   ctx.setBlendMode(.clear)
                   ctx.setStrokeColor(UIColor.clear.cgColor)
               }

               ctx.move(to: from)
               ctx.addLine(to: to)
               ctx.strokePath()
           }

           let newMask = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()

           maskImage = newMask
           maskLayer.contents = newMask?.cgImage
       }

       static func toGray(image: UIImage) -> UIImage {
           guard let ci = CIImage(image: image),
                 let f = CIFilter(name: "CIPhotoEffectMono") else { return image }
           f.setValue(ci, forKey: kCIInputImageKey)
           let ctx = CIContext()
           if let out = f.outputImage,
              let cg = ctx.createCGImage(out, from: out.extent) {
               // giữ nguyên orientation ảnh gốc -> không bị đảo
               return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
           }
           return image
       }
   }
