//
//  OverlayView.swift
//  MangaGlass
//
//  Created by 강민우 on 7/15/25.
//

//
//  OverlayView.swift
//  MangaGlass
//

import SwiftUI

struct OverlayView: View {
    @ObservedObject var appState: AppState
    let overlayID: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                // OCR 박스 시각화
//                ForEach(appState.ocrResults) { box in
//                    Rectangle()
//                        .stroke(Color.red, lineWidth: 2)
//                        .frame(
//                            width: box.frame.width,
//                            height: box.frame.height
//                        )
//                        .position(
//                            x: box.frame.midX,
//                            y: geometry.size.height - box.frame.midY
//                        )
//                }
                // 🔷 Overlay 창 전체 보더
                Rectangle()
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}



//import SwiftUI
//
//struct OverlayView: View {
//    @ObservedObject var appState: AppState
//    let overlayID: String
//
//    var body: some View {
//        ZStack {
//            Color.clear  // 완전 투명 배경
//
//            // OCR 결과 시각화 (번역이 수행되지 않은 경우에만 표시)
//            if appState.translatedTexts.isEmpty {
//                ForEach(appState.ocrResults) { box in
//                    Rectangle()
//                        .stroke(Color.red, lineWidth: 2)
//                        .frame(width: box.frame.width, height: box.frame.height)
//                        .position(x: box.frame.midX, y: box.frame.midY)                }
//            }
//
//            // 캡처 영역 테두리 (항상 표시)
//            RoundedRectangle(cornerRadius: 4)
//                .stroke(Color.blue.opacity(0.7), lineWidth: 2)
//                .padding(2)
//        }
//        .edgesIgnoringSafeArea(.all)
//        .background(Color.clear)
//    }
//}

