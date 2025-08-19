//
//  PaperSize.swift
//  PrintImage
//
//  Created by Alex Tran on 1/8/25.
//

import UIKit

struct ItemTool {
    let name: String
    let type: Int
    let nameImage: String
}

struct FilterInfo {
    let display: String
    let ciName: String
    init(_ display: String, _ ciName: String) {
        self.display = display
        self.ciName = ciName
    }
}

