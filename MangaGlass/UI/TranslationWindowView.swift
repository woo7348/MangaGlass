//
//  TranslationWindowView.swift
//  MangaGlass
//
//  Created by 강민우 on 7/19/25.
//
//import SwiftUI
//
//struct TranslationWindowView: View {
//    @ObservedObject var appState: AppState
//
//    var body: some View {
//        ZStack {
//            // 배경 블러 + 유리 효과
//            RoundedRectangle(cornerRadius: 25)
//                .fill(.ultraThinMaterial)
//                .background(.ultraThinMaterial)
//                .cornerRadius(25)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 25)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
//                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
//
//            VStack(spacing: 20) {
//                // 앱 이름
//                Text("MangaGlass")
//                    .font(.system(size: 28, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//
//                // 언어 선택
//                HStack(spacing: 12) {
//                    Picker("From", selection: $appState.sourceLanguage) {
//                        LanguageOptions()
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                    .frame(width: 120)
//                    .background(Color.white.opacity(0.1))
//                    .cornerRadius(10)
//
//                    Image(systemName: "arrow.right")
//                        .foregroundColor(.white.opacity(0.8))
//
//                    Picker("To", selection: $appState.targetLanguage) {
//                        LanguageOptions()
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                    .frame(width: 120)
//                    .background(Color.white.opacity(0.1))
//                    .cornerRadius(10)
//                }
//
//                // 세로쓰기 토글
//                Toggle("Vertical Writing", isOn: $appState.isVerticalWriting)
//                    .toggleStyle(SwitchToggleStyle(tint: .purple))
//                    .foregroundColor(.white)
//
//                // 말풍선 병합 모드 토글
//                Toggle("Bubble Grouping Mode", isOn: Binding(
//                    get: { appState.mergeMode == .bubbleGrouping },
//                    set: { appState.mergeMode = $0 ? .bubbleGrouping : .unified }
//                ))
//                .toggleStyle(SwitchToggleStyle(tint: .blue))
//                .foregroundColor(.white)
//
//                // 병합 간격 설정 슬라이더
//                if appState.mergeMode == .bubbleGrouping {
//                    VStack(spacing: 10) {
//                        Text("Bubble Merge Threshold")
//                            .font(.headline)
//                            .foregroundColor(.white.opacity(0.8))
//
//                        HStack {
//                            Text("X: ")
//                                .foregroundColor(.white)
//                            Slider(value: $appState.mergeXThreshold, in: 0...200, step: 1)
//                                .accentColor(.cyan)
//                            Text("\(Int(appState.mergeXThreshold))")
//                                .foregroundColor(.white)
//                                .frame(width: 40)
//                        }
//
//                        HStack {
//                            Text("Y: ")
//                                .foregroundColor(.white)
//                            Slider(value: $appState.mergeYThreshold, in: 0...200, step: 1)
//                                .accentColor(.cyan)
//                            Text("\(Int(appState.mergeYThreshold))")
//                                .foregroundColor(.white)
//                                .frame(width: 40)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//
//                // 번역 실행 버튼
//                Button(action: {
//                    if let image = appState.capturedImage {
//                        appState.runOCR(on: image)
//                    }
//                }) {
//                    Text("Translate")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(LinearGradient(
//                            colors: [.purple, .blue],
//                            startPoint: .leading,
//                            endPoint: .trailing))
//                        .cornerRadius(12)
//                        .foregroundColor(.white)
//                        .shadow(radius: 5)
//                }
//
//                // 🔽 번역 결과 출력
//                if !appState.translatedTexts.isEmpty {
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 12) {
//                            ForEach(appState.translatedTexts) { text in
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text("🈶 \(text.original)")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                    Text("🌐 \(text.translated)")
//                                        .font(.body)
//                                        .foregroundColor(.white)
//                                }
//                                .padding()
//                                .background(Color.white.opacity(0.1))
//                                .cornerRadius(10)
//                            }
//                        }
//                        .padding(.top, 10)
//                    }
//                    .frame(maxHeight: 280)
//                }
//            }
//            .padding()
//        }
//        .frame(width: 420)
//        .padding()
//    }
//}
//
//@ViewBuilder
//private func LanguageOptions() -> some View {
//    Group {
//        Text("Korean").tag("ko")
//        Text("English").tag("en")
//        Text("Japanese").tag("ja")
//        Text("Chinese").tag("zh-CN")
//        Text("Spanish").tag("es")
//        Text("French").tag("fr")
//        Text("Arabic").tag("ar")
//        Text("German").tag("de")
//        Text("Hindi").tag("hi")
//        Text("Russian").tag("ru")
//        Text("Italian").tag("it")
//        Text("Vietnamese").tag("vi")
//        Text("Turkish").tag("tr")
//    }
//}

import SwiftUI

struct TranslationWindowView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 🔤 언어 선택
            Group {
                Text("원본 언어 (From)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Source Language", selection: $appState.sourceLanguage) {
                    Text("Auto (Detect)").tag("auto")
                    Text("Korean").tag("ko")
                    Text("Japanese").tag("ja")
                    Text("English").tag("en")
                    Text("Chinese (Simplified)").tag("zh-CN")
                    Text("Chinese (Traditional)").tag("zh-TW")
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("Arabic").tag("ar")
                    Text("German").tag("de")
                    Text("Hindi").tag("hi")
                    Text("Russian").tag("ru")
                    Text("Italian").tag("it")
                    Text("Vietnamese").tag("vi")
                    Text("Thai").tag("th")
                    Text("Lao").tag("lo")
                    Text("Myanmar").tag("my")
                    Text("Indonesian").tag("id")
                    Text("Malay").tag("ms")
                    Text("Khmer (Cambodian)").tag("km")
                    Text("Tagalog (Filipino)").tag("tl")
                    Text("Turkish").tag("tr")
                    Text("Hebrew").tag("iw") // 이스라엘어
                }
                .pickerStyle(PopUpButtonPickerStyle())

                Text("번역 언어 (To)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Target Language", selection: $appState.targetLanguage) {
                    Text("Korean").tag("ko")
                    Text("Japanese").tag("ja")
                    Text("English").tag("en")
                    Text("Chinese (Simplified)").tag("zh-CN")
                    Text("Chinese (Traditional)").tag("zh-TW")
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("Arabic").tag("ar")
                    Text("German").tag("de")
                    Text("Hindi").tag("hi")
                    Text("Russian").tag("ru")
                    Text("Italian").tag("it")
                    Text("Vietnamese").tag("vi")
                    Text("Thai").tag("th")
                    Text("Lao").tag("lo")
                    Text("Myanmar").tag("my")
                    Text("Indonesian").tag("id")
                    Text("Malay").tag("ms")
                    Text("Khmer (Cambodian)").tag("km")
                    Text("Tagalog (Filipino)").tag("tl")
                    Text("Turkish").tag("tr")
                    Text("Hebrew").tag("iw")
                }
                .pickerStyle(PopUpButtonPickerStyle())
            }

            Divider()

            // 🧠 병합 모드 선택
            VStack(alignment: .leading) {
                Text("읽기 방식")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("Merge Mode", selection: $appState.mergeMode) {
                    Text("가로 읽기").tag(MergeMode.unified)
                    Text("세로 읽기(일본 만화)").tag(MergeMode.verticalBlockMerge)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            // 📐 정렬 기준 설정
            VStack(alignment: .leading) {
                Text("읽기 순서")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("Sort Axis", selection: $appState.sortAxis) {
                    Text("위 → 아래 → 왼 → 오").tag(SortAxis.yFirst)
                    Text("왼 → 오 → 위 → 아래").tag(SortAxis.xFirst)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            // 📏 병합 간격 설정
            VStack(alignment: .leading) {
                Text("병합 간격")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text("X: \(Int(appState.mergeXThreshold))")
                    Slider(value: $appState.mergeXThreshold, in: 500...1700)
                }

                HStack {
                    Text("Y: \(Int(appState.mergeYThreshold))")
                    Slider(value: $appState.mergeYThreshold, in: 200...1700)
                }
            }

            Divider()

            // 🔁 번역 실행 버튼
            Button(action: {
                appState.captureOverlayArea { image in
                    if let image = image {
                        appState.runOCR(on: image)
                    } else {
                        print("⚠️ 이미지 캡처 실패")
                    }
                }
            }) {
                Text("Translate")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            
            Button {
                appState.captureByDragAndTranslate()
            } label: {
                Text("영역 선택 후 번역")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }

            Divider()

            // 🌍 번역 결과
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(appState.translatedTexts) { text in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🈶 [\(text.index)] 원문: \(text.original)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .textSelection(.enabled)
                            Text("🌐 번역: \(text.translated)")
                                .font(.body)
                                .foregroundColor(.primary)
                                .textSelection(.enabled)
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 360, idealWidth: 380, maxWidth: .infinity,
               minHeight: 420, idealHeight: 460, maxHeight: .infinity)
    }
}

