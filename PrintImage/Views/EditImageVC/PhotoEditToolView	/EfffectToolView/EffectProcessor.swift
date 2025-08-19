//
//  EffectProcessor.swift
//  PrintImage
//
//  Created by Alex Tran on 14/8/25.
//

import Foundation
import UIKit
import CoreImage

class EffectProcessor {
    private static let context = CIContext(options: nil)

    static func applyFilter(name: String, to image: UIImage) -> UIImage {
        // "None" hoặc rỗng → trả ảnh gốc
        guard !name.isEmpty else { return image }
        guard let ciImage = CIImage(image: image, options: [.applyOrientationProperty: true]) else {
            return image
        }

        // --- CASE ĐẶC BIỆT: CISpotLight ---
        if name == "CISpotLight" {
            guard let spot = CIFilter(name: "CISpotLight"),
                  let composite = CIFilter(name: "CISourceOverCompositing") else {
                return image
            }

            let extent = ciImage.extent
            let cx = extent.midX
            let cy = extent.midY
            let z  = max(extent.width, extent.height) // “độ cao” đèn

            // BẮT BUỘC set đầy đủ input cho CISpotLight
            spot.setValue(ciImage, forKey: kCIInputImageKey)
            spot.setValue(CIVector(x: cx, y: cy, z: z),  forKey: "inputLightPosition")
            spot.setValue(CIVector(x: cx, y: cy, z: 0),  forKey: "inputLightPointsAt")
            spot.setValue(3.0,                           forKey: "inputBrightness")     // tăng/giảm tùy ý
            spot.setValue(0.2,                           forKey: "inputConcentration")  // 0.0–1.0
            spot.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor")     // dùng init RGB an toàn

            guard let spotImage = spot.outputImage else { return image }

            // Blend ánh sáng lên ảnh gốc để không bị nền đen
            composite.setValue(spotImage, forKey: kCIInputImageKey)
            composite.setValue(ciImage,   forKey: kCIInputBackgroundImageKey)

            guard let out = composite.outputImage?.cropped(to: extent),
                  let cg  = context.createCGImage(out, from: extent) else {
                return image
            }
            return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
        }

        // --- CÁC FILTER CÒN LẠI ---
        guard let f = CIFilter(name: name) else { return image }
        f.setValue(ciImage, forKey: kCIInputImageKey)

        switch name {
        case "CIHueAdjust":
            f.setValue(Float.pi/2, forKey: kCIInputAngleKey)

        case "CIHighlightShadowAdjust":
            f.setValue(1.0, forKey: "inputHighlightAmount")

        case "CIBloom", "CIGloom":
            f.setValue(1.0, forKey: kCIInputIntensityKey)

        case "CIPixellate":
            f.setValue(10.0, forKey: kCIInputScaleKey)

        case "CIColorPosterize":
            // Tùy chọn: số mức màu (mặc định 6)
            // f.setValue(8.0, forKey: "inputLevels")
            break

        default:
            break
        }

        let extent = ciImage.extent
        guard let out = f.outputImage?.cropped(to: extent),
              let cg  = context.createCGImage(out, from: extent) else {
            return image
        }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
