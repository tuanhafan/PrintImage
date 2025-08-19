//
//  File.swift
//  PrintImage
//
//  Created by Alex Tran on 11/8/25.
//

import UIKit
import CoreImage

final class BrightnessSaturationView: UIView {
    private let brightnessSlider = HorizontalBrightnessSlider()
    private let saturationSlider = HorizontalSaturationSlider()
    
    var onImageUpdated: ((UIImage) -> Void)?
    
    private var originalCIImage: CIImage?
    private var originalUIImage: UIImage? // Lưu ảnh gốc để giữ orientation
    private let context = CIContext()
    
    // Giá trị hiện tại của sliders
    private var currentBrightness: Float = 0.0  // -1 ... 1
    private var currentSaturation: Float = 1.0  // 0 ... 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSliders()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSliders()
    }
    
    private func setupSliders() {
        let stack = UIStackView(arrangedSubviews: [brightnessSlider, saturationSlider])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        brightnessSlider.onBrightnessChanged = { [weak self] value in
            guard let self = self else { return }
            // map slider 0...1 -> brightness -1...1
            self.currentBrightness = Float(value * 2 - 1)
            self.applyFilter()
        }
        
        saturationSlider.onSaturationChanged = { [weak self] value in
            guard let self = self else { return }
            // map slider 0...1 -> saturation 0...2
            self.currentSaturation = Float(value * 2)
            self.applyFilter()
        }
    }
    
    func setImage(_ image: UIImage) {
        originalUIImage = image // lưu để lấy orientation & scale
        
        if let cg = image.cgImage {
            originalCIImage = CIImage(cgImage: cg)
        } else {
            originalCIImage = CIImage(image: image)
        }
        
        // Reset slider
        currentBrightness = 0.0
        currentSaturation = 1.0
        brightnessSlider.value = 0.5
        saturationSlider.value = 0.5
        applyFilter()
    }
    
    private func applyFilter() {
        guard let input = originalCIImage,
              let original = originalUIImage else { return }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(input, forKey: kCIInputImageKey)
        filter?.setValue(currentBrightness, forKey: kCIInputBrightnessKey)
        filter?.setValue(currentSaturation, forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter?.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        // Giữ nguyên scale và orientation của ảnh gốc
        let result = UIImage(cgImage: cgImage,
                             scale: original.scale,
                             orientation: original.imageOrientation)
        
        DispatchQueue.main.async {
            self.onImageUpdated?(result)
        }
    }
}
