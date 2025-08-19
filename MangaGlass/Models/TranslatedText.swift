//
//  TranslatedText.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import Foundation
import CoreGraphics

struct TranslatedText: Identifiable {
    let id = UUID()
    let index: Int
    let original: String
    let translated: String
    let frame: CGRect

    // ❌ 문제였던 부분
    // private init(original: String, translated: String, frame: CGRect)

    // ✅ 접근 가능한 생성자 선언
    init(index: Int, original: String, translated: String, frame: CGRect) {
        self.original = original
        self.translated = translated
        self.frame = frame
        self.index = index
    }
}
