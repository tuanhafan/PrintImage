//
//  ButtonIcon.swift
//  PrintImage
//
//  Created by Alex Tran on 15/7/25.
//

import UIKit

class ButtonIcon {

    private static var shared = ButtonIcon()

    static func createIconButton(systemName: String, badgeNumber: Int? = nil) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: ResponsiveLayout.symbolSize(), weight: .regular)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }
    
    static func btnInCell(_ systemName:String) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }
}


