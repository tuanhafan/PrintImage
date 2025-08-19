//
//  CreateSpotlightImage.swift
//  PrintImage
//
//  Created by Alex Tran on 14/8/25.
//

import Foundation
import UIKit
import CoreImage

func createSpotlightImage(from image: UIImage,
                          lightPosition: CGPoint,
                          lightColor: UIColor = .white,
                          brightness: CGFloat = 3.0,
                          concentration: CGFloat = 0.5) -> UIImage? {
    
    guard let ciImage = CIImage(image: image) else { return nil }
    let context = CIContext()
    
    // Chuyển UIColor sang CIColor
    let ciLightColor = CIColor(color: lightColor)
    
    // Kích thước ảnh
    let width = ciImage.extent.width
    let height = ciImage.extent.height
    
    // Spotlight filter
    guard let filter = CIFilter(name: "CISpotLight") else { return nil }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    
    // Vị trí nguồn sáng (z = độ cao ánh sáng so với ảnh)
    filter.setValue(CIVector(x: lightPosition.x, y: height - lightPosition.y, z: 300),
                    forKey: "inputLightPosition")
    
    // Hướng chiếu sáng (ở đây chiếu vào tâm ảnh)
    filter.setValue(CIVector(x: width / 2, y: height / 2, z: 0),
                    forKey: "inputLightPointsAt")
    
    filter.setValue(ciLightColor, forKey: "inputColor")
    filter.setValue(brightness, forKey: "inputBrightness")
    filter.setValue(concentration, forKey: "inputConcentration")
    
    // Xuất ảnh mới
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
    
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
}
