//
//  CurveUtils.swift
//  PrintImage
//
//  Created by Alex Tran on 16/8/25.
//

import Foundation
import UIKit

// Sinh LUT từ mảng control points
func generateLUT(from uiPoints: [CGPoint], size: Int = 256) -> [UInt8] {
    guard uiPoints.count >= 2 else {
        // identity LUT
        return (0..<size).map { UInt8($0) }
    }

    // 1) sort theo x, clamp 0..1 và đổi hệ y UI -> y ảnh
    var pts = uiPoints
        .sorted { $0.x < $1.x }
        .map { CGPoint(x: min(max($0.x, 0), 1),
                       y: min(max(1 - $0.y, 0), 1)) } // flip Y cho ảnh

    // 2) đảm bảo x tăng nghiêm ngặt (tránh chia 0)
    let eps: CGFloat = 1.0 / CGFloat(size * 10)
    for i in 1..<pts.count {
        if pts[i].x <= pts[i-1].x {
            pts[i].x = min(pts[i-1].x + eps, 1)
        }
    }

    // 3) đảm bảo có x=0 và x=1
    if pts.first!.x > 0 { pts.insert(CGPoint(x: 0, y: pts.first!.y), at: 0) }
    if pts.last!.x  < 1 { pts.append(CGPoint(x: 1, y: pts.last!.y)) }

    // 4) nội suy tuyến tính theo đoạn
    var lut = [UInt8](repeating: 0, count: size)
    var seg = 0
    for i in 0..<size {
        let x = CGFloat(i) / CGFloat(size - 1)
        while seg < pts.count - 2 && x > pts[seg+1].x { seg += 1 }
        let p0 = pts[seg], p1 = pts[seg+1]
        let w = max(p1.x - p0.x, eps)
        let t = (x - p0.x) / w
        let y = p0.y + t * (p1.y - p0.y)
        let clamped = min(max(y, 0), 1)
        lut[i] = UInt8(clamping: Int(round(clamped * 255)))
    }

    // 5) đảm bảo monotonic không giảm (tránh "đảo" gây mất ảnh)
    for i in 1..<size {
        if lut[i] < lut[i-1] { lut[i] = lut[i-1] }
    }

    return lut
}
