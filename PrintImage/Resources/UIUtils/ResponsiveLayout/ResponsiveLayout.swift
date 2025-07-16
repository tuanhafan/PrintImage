//
//  ResponsiveLayout.swift
//  PrintImage
//
//  Created by Alex Tran on 15/7/25.
//

import UIKit

enum ResponsiveLayout {
    
    static func buttonSize() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return 60
        case .phone: return 38
        default: return 36
        }
    }
    
    static func symbolSize() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 32
        case .phone:
            let screenWidth = UIScreen.main.bounds.width
            return screenWidth >= 390 ? 20 : 18  // lớn hơn cho iPhone Plus/ProMax
        default:
            return 18
        }
    }
    
    static func fontSize(base: CGFloat) -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return base * 1.5
        case .phone: return base
        default: return base * 0.95
        }
    }
    
    static func emptyButtonSize() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 120
        case .phone:
            return 80
        default:
            return 100
        }
    }
    
    static func stackSpacing() -> CGFloat {
        let width = UIScreen.main.bounds.width
        return width > 600 ? 60 : 32
    }
    
    static func bottomSpacing() -> CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? -60 : -30
    }
    
    static func horizontalMargin() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 64 // iPad: margin rộng hơn
        case .phone:
            return 28 // iPhone: margin mặc định
        default:
            return 28
        }
    }
    
    
}
