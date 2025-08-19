//
//  UIImage.swift
//  PrintImage
//
//  Created by Alex Tran on 11/8/25.
//

import UIKit
import Accelerate

extension UIImage {
    func applying(transform: CGAffineTransform) -> UIImage? {
        // Tính kích thước mới sau transform
        var newRect = CGRect(origin: .zero, size: size).applying(transform)
        newRect.origin = .zero // reset lại gốc
        
        let newSize = CGSize(width: abs(newRect.width), height: abs(newRect.height))
        
        // Tạo context mới
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Di chuyển tâm context về giữa ảnh mới
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        
        // Áp dụng transform
        context.concatenate(transform)
        
        // Vẽ ảnh gốc ở tâm
        draw(in: CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        ))
        
        // Lấy ảnh kết quả
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
extension UIImage {
    func adjustBrightness(_ value: CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: self) else { return self }
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputBrightnessKey)
        guard let output = filter.outputImage else { return self }
        return UIImage(ciImage: output)
    }

    func adjustSaturation(_ value: CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: self) else { return self }
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputSaturationKey)
        guard let output = filter.outputImage else { return self }
        return UIImage(ciImage: output)
    }
}
extension UIImage {
    /// Trả về ảnh orientation .up (không còn metadata xoay)
    func normalizedUp() -> UIImage {
        if imageOrientation == .up { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
    }

    /// Lật ngang (mirror theo trục dọc) – AN TOÀN orientation
    func flippedHorizontallySafe() -> UIImage {
        let img = self.normalizedUp()
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = img.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: img.size, format: format).image { ctx in
            let cg = ctx.cgContext
            cg.translateBy(x: img.size.width, y: 0)
            cg.scaleBy(x: -1, y: 1)
            img.draw(in: CGRect(origin: .zero, size: img.size))
        }
    }

    /// Lật dọc (mirror theo trục ngang) – AN TOÀN orientation
    func flippedVerticallySafe() -> UIImage {
        let img = self.normalizedUp()
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = img.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: img.size, format: format).image { ctx in
            let cg = ctx.cgContext
            cg.translateBy(x: 0, y: img.size.height)
            cg.scaleBy(x: 1, y: -1)
            img.draw(in: CGRect(origin: .zero, size: img.size))
        }
    }
}

extension UIImage {
    func applyingLUT(_ lut: [UInt8]) -> UIImage? {
            guard let cgImage = self.cgImage else { return nil }

            // Khai báo error dùng chung cho vImage
            var error: vImage_Error = kvImageNoError

            // Định dạng ARGB8888
            var format = vImage_CGImageFormat(
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                colorSpace: Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB()),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), // ARGB
                version: 0,
                decode: nil,
                renderingIntent: .defaultIntent
            )

            // Buffer nguồn
            var src = vImage_Buffer()
            defer { free(src.data) }
            error = vImageBuffer_InitWithCGImage(&src, &format, nil, cgImage, vImage_Flags(kvImageNoFlags))
            guard error == kvImageNoError else { return nil }

            // Buffer đích
            var dst = vImage_Buffer()
            error = vImageBuffer_Init(&dst, src.height, src.width, format.bitsPerPixel, vImage_Flags(kvImageNoFlags))
            guard error == kvImageNoError else { return nil }

            // Áp LUT cho R,G,B; giữ Alpha nguyên (identity)
            let identityA = (0...255).map { UInt8($0) }
            var A = identityA, R = lut, G = lut, B = lut

            error = vImageTableLookUp_ARGB8888(&src, &dst, &A, &R, &G, &B, vImage_Flags(kvImageNoFlags))
            guard error == kvImageNoError else { free(dst.data); return nil }

            // Lật dọc để khớp hệ toạ độ UIKit (tránh dùng .Mirrored)
            error = vImageVerticalReflect_ARGB8888(&dst, &dst, vImage_Flags(kvImageNoFlags))
            guard error == kvImageNoError else { free(dst.data); return nil }

            error = vImageHorizontalReflect_ARGB8888(&dst, &dst, vImage_Flags(kvImageNoFlags))
            guard error == kvImageNoError else { free(dst.data); return nil }
            // Tạo CGImage; vImage sẽ tự free dst qua callback
            let result = vImageCreateCGImageFromBuffer(
                &dst, &format,
                { _, buf in free(buf) },
                nil,
                vImage_Flags(kvImageNoFlags),
                &error
            )
            guard let cgOut = result?.takeRetainedValue(), error == kvImageNoError else { return nil }

            return UIImage(cgImage: cgOut, scale: self.scale, orientation: .up)
        }
    }
