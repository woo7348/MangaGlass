//
//  OCRTextBox.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import Foundation
import CoreGraphics

struct OCRTextBox: Identifiable {
    let id = UUID()
    let text: String
    let frame: CGRect
    let index: Int
}
