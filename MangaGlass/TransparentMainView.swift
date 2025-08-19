//
//  TransparentMainView.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import SwiftUI

struct TransparentMainView: View {
    var body: some View {
        Color.clear // 완전 투명
            .frame(width: 1, height: 1) // 거의 보이지 않게
    }
}
