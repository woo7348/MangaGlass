//
//  TranslatedTextRow.swift
//  MangaGlass
//
//  Created by 강민우 on 7/18/25.
//

import SwiftUI

struct TranslatedTextRow: View {
    let translated: TranslatedText

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔤 원문: \(translated.original)")
                .font(.caption)
                .foregroundColor(.gray)
            Text("🌍 번역: \(translated.translated)")
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(6)
        .background(Color(.systemGray))
        .cornerRadius(6)
    }
}
