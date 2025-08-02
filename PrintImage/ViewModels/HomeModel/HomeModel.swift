//
//  HomeModel.swift
//  PrintImage
//
//  Created by Alex Tran on 2/8/25.
//

import Foundation
import UIKit

class HomeModel{
    var onImagesPicked: (([UIImage]) -> Void)?
    
    func handlePickedImages(_ images: [UIImage]) {
       
        onImagesPicked?(images)
    }
}
