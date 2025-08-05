//
//  EditImageModel.swift
//  PrintImage
//
//  Created by Alex Tran on 1/8/25.
//

import UIKit
class EditImageModel {
    let paperSizes : [PaperSize] = [
        PaperSize(name: "Chiều rộng 3.5 cm",value:1),
        PaperSize(name: "4\" x 6\"",value:2),
        PaperSize(name: "35 x 45 mm",value:3),
        PaperSize(name: "2\" x 2\"",value:4),
        PaperSize(name: "6 x 8 cm",value:5),
        PaperSize(name: "6\" x 4\"",value:6),
        PaperSize(name: "21 x 29.7 cm",value:7),
        PaperSize(name: "8.5\" x 11\"",value:8),
        PaperSize(name: "5.5\" x 8.5\"",value:9),
    ]
    func changeSizehandler(with type : Int, currentImage : (width: CGFloat,height:CGFloat),in parentView: UIView) -> (size:CGSize,frameSize:(width:CGFloat,height:CGFloat),typeSize:Int){
        
        let caculator35 = calculateImageSize35(currentImage.width,currentImage.height)
        var size : (size:CGSize,frameSize:(width:CGFloat,height:CGFloat),typeSize:Int) =
        (calculateImageSize(for: (currentImage.width,currentImage.height), in:parentView),
         (caculator35.width,caculator35.height),1)
        switch type {
        case 1:
            size = (calculateImageSize(for: (currentImage.width,currentImage.height), in: parentView),(caculator35.width,caculator35.height),1)
        case 2: size = (calculateImageSize(for: (310,600), in: parentView),(4,6),2)
        case 3: size = (calculateImageSize(for: (410,600), in: parentView),(35,45),0)
        case 4: size = (calculateImageSize(for: (500,500), in: parentView),(2,2),2)
        case 5: size = (calculateImageSize(for: (390,600), in: parentView),(6,8),1)
        case 6: size = (calculateImageSize(for: (600,350), in: parentView),(6,4),2)
        case 7: size = (calculateImageSize(for: (360,600), in: parentView),(21,29.7),1)
        case 8: size = (calculateImageSize(for: (400,600), in: parentView),(8.5,11),2)
        case 9: size = (calculateImageSize(for: (300,600), in: parentView),(5.5,8.5),2)
        default: break
        }
        return size
    }
    
    func calculateImageSize(for size:(width:CGFloat,height:CGFloat), in parentView: UIView) -> CGSize {
        guard size.width > 0, size.height > 0 else { return .zero }
        
        let originalWidth = size.width
        let originalHeight = size.height
        let aspectRatio = originalWidth / originalHeight
        
        let maxParentWidth = parentView.bounds.width
        let maxParentHeight = parentView.bounds.height
        
        if originalHeight > originalWidth {
            // Chiều cao lớn hơn hoặc bằng chiều rộng → scale theo chiều cao
            let targetHeight = maxParentHeight * 0.9
            let targetWidth = targetHeight * aspectRatio
            return CGSize(width: targetWidth, height: targetHeight)
        } else if originalHeight < originalWidth {
            // Chiều rộng lớn hơn chiều cao → scale theo chiều rộng
            let targetWidth = maxParentWidth * 0.9
            let targetHeight = targetWidth / aspectRatio
            return CGSize(width: targetWidth, height: targetHeight)
        } else{
            let targetWidth = maxParentWidth * 0.8
            let targetHeight = maxParentWidth * 0.8
            return CGSize(width: targetWidth, height: targetHeight)
        }
    }
    
    func changeSizehandlerSwap(with type : Int, currentImage : (width: CGFloat,height:CGFloat),in parentView: UIView) -> (CGSize){
        
        
        
        var size :CGSize = calculateImageSize(for: (currentImage.height,currentImage.width), in:parentView)
        
        switch type {
        case 1:
            size = calculateImageSize(for: (currentImage.height, currentImage.width), in: parentView)
        case 2:
            size = calculateImageSize(for: (600, 310), in: parentView)
        case 3:
            size = calculateImageSize(for: (600, 410), in: parentView)
        case 4:
            size = calculateImageSize(for: (500, 500), in: parentView)
        case 5:
            size = calculateImageSize(for: (600, 390), in: parentView)
        case 6:
            size = calculateImageSize(for: (350, 600), in: parentView)
        case 7:
            size = calculateImageSize(for: (600, 360), in: parentView)
        case 8:
            size = calculateImageSize(for: (600, 400), in: parentView)
        case 9:
            size = calculateImageSize(for: (600, 300), in: parentView)
        default:
            break
        }
        return size
    }
    
    func calculateImageSize35(_ width: CGFloat,_ height:CGFloat) -> (width:CGFloat,height:CGFloat) {
        let originalWidth: CGFloat = width
        let originalHeight: CGFloat = height
        let fixedWidthCM: CGFloat = 3.5
        let aspectRatio = originalHeight / originalWidth
        let heightCM = fixedWidthCM * aspectRatio
        let roundedHeightCM = (heightCM * 100).rounded() / 100
        return (3.5,roundedHeightCM)
    }
    
    func createArraySize(_ type:Int, oldArr:[Int]) -> [Int]{
        var arr : [Int] = oldArr
        switch type {
        case 1,5,7:
            arr[1] = type
        case 2,4,6,8,9:
            arr[2] = type
        default:
            break
        }
        return arr
    }
}
