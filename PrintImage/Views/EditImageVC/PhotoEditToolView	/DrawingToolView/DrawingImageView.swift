//
//  BrushSizeSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 15/8/25.
//

import Foundation
import UIKit

class DrawingImageView: UIImageView {
    
    var brushColor: UIColor = .black
    var brushSize: CGFloat = 1
    var isErasing: Bool = false 
    private var lastPoint: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first,
                  let lastPoint = lastPoint else { return }
            
            let currentPoint = touch.location(in: self)
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            image?.draw(in: bounds)
            
            if let context = UIGraphicsGetCurrentContext() {
                context.setLineCap(.round)
                context.setLineWidth(brushSize)
                
                if isErasing {
                    // Bút xoá: dùng blend mode clear để xóa nét vẽ
                    context.setBlendMode(.clear)
                    context.setStrokeColor(UIColor.clear.cgColor)
                } else {
                    // Bút vẽ bình thường
                    context.setBlendMode(.normal)
                    context.setStrokeColor(brushColor.cgColor)
                }
                
                context.move(to: lastPoint)
                context.addLine(to: currentPoint)
                context.strokePath()
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.lastPoint = currentPoint
        }
    
    
}
