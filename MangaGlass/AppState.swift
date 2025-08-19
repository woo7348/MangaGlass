//
//  AppState.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import Foundation
import Combine
import AppKit
import CoreGraphics

enum MergeMode {
    case unified              // 문장 통합형
    case verticalBlockMerge   // 일본어 세로쓰기 전용
}

enum SortAxis {
    case yFirst  // 위 → 아래 → 왼 → 오
    case xFirst  // 왼 → 오 → 위 → 아래
}

final class AppState: ObservableObject {
    // MARK: - Overlay 상태
    @Published var overlayFrame: CGRect = .zero
    @Published var isOverlaySynced: Bool = false
    @Published var isOverlayVisible: Bool = true

    // MARK: - OCR & 번역
    @Published var ocrResults: [OCRTextBox] = []
    @Published var capturedImage: NSImage? = nil
    @Published var translatedTexts: [TranslatedText] = []

    // MARK: - 설정
    @Published var sourceLanguage: String = "ja"
    @Published var targetLanguage: String = "ko"
    @Published var mergeMode: MergeMode = .unified
    @Published var sortAxis: SortAxis = .yFirst
    @Published var mergeXThreshold: CGFloat = 50
    @Published var mergeYThreshold: CGFloat = 100
    @Published var xThreshold: CGFloat = 50
    @Published var yThreshold: CGFloat = 100
    
    
    // MARK: - 언어감지 자동모드 추가
    @Published var autoDetectSource: Bool = true

    private let translationService: TranslationService

    init() {
        let apiKey = SecretsManager.shared.apiKey
        self.translationService = TranslationService(apiKey: apiKey)
    }

    // MARK: - 일본어 세로쓰기 모드 자동 감지
    private var isJapaneseVerticalMode: Bool {
        return sourceLanguage == "ja" && mergeMode == .verticalBlockMerge
    }

    // MARK: - Overlay 캡처
    func updateOverlayFrame(_ newFrame: CGRect) {
        overlayFrame = newFrame
    }

    func captureOverlayArea(completion: @escaping (NSImage?) -> Void) {
        guard let screen = NSScreen.main else {
            completion(nil)
            return
        }

        let displayID = CGMainDisplayID()
        guard let screenImage = CGDisplayCreateImage(displayID) else {
            completion(nil)
            return
        }

        let scale = screen.backingScaleFactor
        let excludedTop: CGFloat = 24.0

        let cropRect = CGRect(
            x: overlayFrame.origin.x * scale,
            y: (screen.frame.height - overlayFrame.origin.y - overlayFrame.height + excludedTop) * scale,
            width: overlayFrame.width * scale,
            height: (overlayFrame.height - excludedTop) * scale
        )

        guard let croppedImage = screenImage.cropping(to: cropRect) else {
            completion(nil)
            return
        }

        let nsImage = NSImage(cgImage: croppedImage, size: .zero)
        DispatchQueue.main.async {
            self.capturedImage = nsImage
            completion(nsImage)
        }
    }

    // MARK: - OCR 실행
    func runOCR(on image: NSImage) {
        let ocrService = OCRService()
        ocrService.recognizeText(from: image) { [weak self] boxes in
            DispatchQueue.main.async {
                self?.ocrResults = boxes
                self?.updateTranslatedTexts(from: boxes)
            }
        }
    }

    // MARK: - 번역 실행
    func runTranslation() {
        updateTranslatedTexts(from: ocrResults)
    }

    func updateTranslatedTexts(from textBoxes: [OCRTextBox]) {
        switch mergeMode {
        case .unified:
            mergeAsUnified(textBoxes)
        case .verticalBlockMerge:
            mergeAsVerticalBlocks(textBoxes)
        }
    }

    // MARK: - 문장 통합형 병합
    private func mergeAsUnified(_ textBoxes: [OCRTextBox]) {
        let sorted = sortedTextBoxes(textBoxes, axis: sortAxis)
        let mergedText = sorted.map { $0.text }.joined(separator: " ")
        let unifiedBox = OCRTextBox(text: mergedText, frame: .zero, index: 0)

        translationService.translate(
            texts: [unifiedBox],
            source: sourceLanguage,
            target: targetLanguage
        ) { [weak self] results in
            DispatchQueue.main.async {
                self?.translatedTexts = results
            }
        }
    }

    // MARK: - 세로쓰기 병합형
    private func mergeAsVerticalBlocks(_ textBoxes: [OCRTextBox]) {
        let grouped = groupTextBoxes(
            textBoxes,
            xThreshold: mergeXThreshold,
            yThreshold: mergeYThreshold,
            primaryAxis: sortAxis
        )

        let mergedBoxes = grouped.enumerated().map { (index, group) in
            let sortedGroup = sortedTextBoxes(group, axis: sortAxis)
            let mergedText = sortedGroup.map { $0.text }.joined()
            let mergedFrame = sortedGroup.reduce(sortedGroup[0].frame) { $0.union($1.frame) }
            return OCRTextBox(text: mergedText, frame: mergedFrame, index: index)
        }

        translationService.translate(
            texts: mergedBoxes,
            source: sourceLanguage,
            target: targetLanguage
        ) { [weak self] results in
            DispatchQueue.main.async {
                self?.translatedTexts = results
            }
        }
    }

    // MARK: - 그룹화 로직
    private func groupTextBoxes(
        _ textBoxes: [OCRTextBox],
        xThreshold: CGFloat,
        yThreshold: CGFloat,
        primaryAxis: SortAxis
    ) -> [[OCRTextBox]] {
        let sorted = sortedTextBoxes(textBoxes, axis: primaryAxis)
        var grouped: [[OCRTextBox]] = []

        for box in sorted {
            if let lastGroup = grouped.last, let lastBox = lastGroup.last {
                let xDiff = abs(box.frame.midX - lastBox.frame.midX)
                let yDiff = abs(box.frame.midY - lastBox.frame.midY)

                let isSameGroup = xDiff <= xThreshold && yDiff <= yThreshold
                if isSameGroup {
                    grouped[grouped.count - 1].append(box)
                } else {
                    grouped.append([box])
                }
            } else {
                grouped.append([box])
            }
        }

        return grouped
    }

    // MARK: - 정렬 로직 통합
    private func sortedTextBoxes(_ boxes: [OCRTextBox], axis: SortAxis) -> [OCRTextBox] {
        return boxes.sorted { a, b in
            if isJapaneseVerticalMode {
                // 일본어 전용: 오른쪽부터 위 → 아래
                if abs(a.frame.minX - b.frame.minX) > 5 {
                    return a.frame.minX > b.frame.minX
                } else {
                    return a.frame.minY < b.frame.minY
                }
            } else {
                switch axis {
                case .yFirst:
                    if abs(a.frame.minY - b.frame.minY) > 5 {
                        return a.frame.minY < b.frame.minY
                    } else {
                        return a.frame.minX < b.frame.minX
                    }
                case .xFirst:
                    if abs(a.frame.minX - b.frame.minX) > 5 {
                        return a.frame.minX < b.frame.minX
                    } else {
                        return a.frame.minY < b.frame.minY
                    }
                }
            }
        }
    }
}
