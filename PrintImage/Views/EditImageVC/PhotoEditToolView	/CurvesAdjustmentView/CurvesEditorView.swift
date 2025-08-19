//
//  CurvesAdjustmentView.swift
//  PrintImage
//
//  Created by Alex Tran on 16/8/25.
//

import Foundation
import UIKit

final class CurvesEditorView: UIView {
        
     // 5 điểm ban đầu nằm trên đường chéo
     var controlPoints: [CGPoint] = [
         CGPoint(x: 0.0,  y: 1.0),
         CGPoint(x: 0.25, y: 0.75),
         CGPoint(x: 0.5,  y: 0.5),
         CGPoint(x: 0.75, y: 0.25),
         CGPoint(x: 1.0,  y: 0.0)
     ]
    private let pointRadius: CGFloat = 6
     private var movingPointIndex: Int?
     var onCurveChanged: (([CGPoint]) -> Void)?
     
     override init(frame: CGRect) {
         super.init(frame: frame)
         backgroundColor = .clear // nền trong suốt
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     override func draw(_ rect: CGRect) {
         guard controlPoints.count >= 2 else { return }
         let context = UIGraphicsGetCurrentContext()
         
         // --- Vẽ grid 4x4 ---
         context?.setStrokeColor(UIColor.black.cgColor)
         context?.setLineWidth(0.5)
         let stepX: CGFloat = rect.width / 4
         let stepY: CGFloat = rect.height / 4
         for i in 0...4 {
             let x = CGFloat(i) * stepX
             context?.move(to: CGPoint(x: x, y: 0))
             context?.addLine(to: CGPoint(x: x, y: rect.height))
         }
         for i in 0...4 {
             let y = CGFloat(i) * stepY
             context?.move(to: CGPoint(x: 0, y: y))
             context?.addLine(to: CGPoint(x: rect.width, y: y))
         }
         context?.strokePath()
         
         // --- Vẽ đường cong Catmull-Rom spline ---
         let sorted = controlPoints // giữ nguyên thứ tự index
         let pts = sorted.map { pointForCurve($0, in: rect) }
         
         let path = UIBezierPath()
         guard pts.count > 1 else { return }
         path.move(to: pts[0])
         
         var splinePts = [pts[0]] + pts + [pts.last!]
         
         for i in 1..<splinePts.count - 2 {
             let p0 = splinePts[i - 1]
             let p1 = splinePts[i]
             let p2 = splinePts[i + 1]
             let p3 = splinePts[i + 2]
             
             let steps = 20
             for j in 0...steps {
                 let t = CGFloat(j) / CGFloat(steps)
                 let tt = t * t
                 let ttt = tt * t
                 
                 let x = 0.5 * ((2 * p1.x) +
                                (-p0.x + p2.x) * t +
                                (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * tt +
                                (-p0.x + 3*p1.x - 3*p2.x + p3.x) * ttt)
                 let y = 0.5 * ((2 * p1.y) +
                                (-p0.y + p2.y) * t +
                                (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * tt +
                                (-p0.y + 3*p1.y - 3*p2.y + p3.y) * ttt)
                 
                 path.addLine(to: CGPoint(x: x, y: y))
             }
         }
         
         UIColor.black.setStroke()
         path.lineWidth = 1
         path.stroke()
         
         // --- Vẽ các điểm control ---
         for point in controlPoints {
             let p = pointForCurve(point, in: rect)
             let circleRect = CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12)
             UIColor.white.setFill()
             context?.fillEllipse(in: circleRect)
             UIColor.black.setStroke()
             context?.strokeEllipse(in: circleRect)
         }
     }
     
     // MARK: - Touch
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let touch = touches.first else { return }
         let location = touch.location(in: self)
         
         for (index, point) in controlPoints.enumerated() {
             let p = pointForCurve(point, in: bounds)
             if hypot(p.x - location.x, p.y - location.y) < 20 {
                 movingPointIndex = index
                 return
             }
         }
     }
     
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let touch = touches.first,
               let index = movingPointIndex else { return }
         let location = touch.location(in: self)
         
         var newX = max(0, min(1, location.x / bounds.width))
         let newY = max(0, min(1, location.y / bounds.height))
         
         // Giữ trục X không vượt qua điểm bên cạnh
         if index > 0 {
             let minX = controlPoints[index - 1].x + 0.01
             if newX < minX { newX = controlPoints[index].x }
         }
         if index < controlPoints.count - 1 {
             let maxX = controlPoints[index + 1].x - 0.01
             if newX > maxX { newX = controlPoints[index].x }
         }
        

         controlPoints[index] = CGPoint(x: newX, y: newY)
         
         setNeedsDisplay()
         onCurveChanged?(controlPoints)
     }
    
    private func pointForCurve(_ point: CGPoint, in rect: CGRect) -> CGPoint {
        // margin để điểm không chạm viền
        let marginX = pointRadius
        let marginY = pointRadius
        
        let x = marginX + point.x * (rect.width - 2 * marginX)
        let y = marginY + point.y * (rect.height - 2 * marginY)
        
        return CGPoint(x: x, y: y)
    }
    
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         movingPointIndex = nil
     }
     
     // MARK: - Helper
     
     func resetPoints() {
         controlPoints = [
             CGPoint(x: 0.0,  y: 1.0),
             CGPoint(x: 0.25, y: 0.75),
             CGPoint(x: 0.5,  y: 0.5),
             CGPoint(x: 0.75, y: 0.25),
             CGPoint(x: 1.0,  y: 0.0)
         ]
         setNeedsDisplay()
         onCurveChanged?(controlPoints)
     }
 }
