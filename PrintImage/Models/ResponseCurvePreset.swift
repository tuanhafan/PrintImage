//
//  ResponseCurvePreset.swift
//  PrintImage
//
//  Created by Alex Tran on 12/8/25.
//

import Foundation
struct ResponseCurvePreset {
    var id: String
    var boundary: Float      // Ngưỡng pixel
    var linearScale: Float   // Contrast scale
    var linearBias: Float    // Brightness
    var gamma: Float         // Gamma correction
}
