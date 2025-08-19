//
//  PhotoEditToolModel.swift
//  PrintImage
//
//  Created by Alex Tran on 9/8/25.
//

import Foundation

class PhotoEditToolModel {
    let listTool : [ItemTool] = [
        ItemTool(name: "Bộ lọc", type: 1, nameImage: "list.and.film"),
        ItemTool(name: "Điều chỉnh", type: 2, nameImage: "wand.and.sparkles.inverse"),
        ItemTool(name: "Hiệu ứng", type: 3, nameImage: "swatchpalette.fill"),
        ItemTool(name: "Lấy nét", type: 4, nameImage: "scope"),
        ItemTool(name: "Lật", type: 5, nameImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right.fill"),
        ItemTool(name: "Vẽ", type: 6, nameImage: "applepencil.and.scribble"),
        ItemTool(name: "Xoá màu", type: 7, nameImage: "theatermask.and.paintbrush.fill"),
        ItemTool(name: "Đường cong sắc độ", type: 8, nameImage: "rainbow"),
        ItemTool(name: "Cảm xúc", type: 9, nameImage: "face.smiling.inverse"),
        ItemTool(name: "Nhãn dán", type: 10, nameImage: "square.2.layers.3d.fill"),
        ItemTool(name: "Văn Bản", type: 11, nameImage: "textformat.characters"),
    ]
    
    let filterNames: [FilterInfo] = [
       
        .init("Noir", "CIPhotoEffectNoir"),
        .init("Mono", "CIPhotoEffectMono"),
        .init("Fade", "CIPhotoEffectFade"),
        .init("Tonal", "CIPhotoEffectTonal"),
        .init("Process", "CIPhotoEffectProcess"),
        .init("Transfer", "CIPhotoEffectTransfer"),
        .init("Chrome", "CIPhotoEffectChrome"),
        .init("Sepia", "CISepiaTone"),
        .init("Vignette", "CIVignette"),
        .init("Linear", "CILinearToSRGBToneCurve"),
        .init("SRGB Linear", "CISRGBToneCurveToLinear"),
        .init("Invert", "CIColorInvert"),
        .init("MonoColor", "CIColorMonochrome")
    ]
    
    let effects: [FilterInfo] = [
        .init("None", ""),
        .init("Spot", "CISpotLight"),
        .init("Hue", "CIHueAdjust"),
        .init("Highlight", "CIHighlightShadowAdjust"),
        .init("Bloom", "CIBloom"),
        .init("Gloom", "CIGloom"),
        .init("Posterize", "CIColorPosterize"),
        .init("Pixelate", "CIPixellate"),
       
    ]
     let emojis: [String] = [
        // Smiley faces
        "😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃",
        "😉","😊","😇","🥰","😍","🤩","😘","😗","☺️","😚","😙",
        "😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔",
        
        // Neutral & negative faces
        "😐","😑","😶","😏","😒","🙄","😬","🤥","😌","😔",
        "😪","🤤","😴","😷","🤒","🤕","🤢","🤮","🤧","🥵",
        "🥶","🥴","😵","🤯","🤠","🥳","😎","🤓","🧐",
        
        // Emotions
        "😕","😟","🙁","☹️","😮","😯","😲","😳","🥺","😦",
        "😧","😨","😰","😥","😢","😭","😱","😖","😣","😞",
        "😓","😩","😫","🥱",
        ]
}
