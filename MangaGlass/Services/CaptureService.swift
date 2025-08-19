//
//  CaptureService.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import ScreenCaptureKit
import AVFoundation
import CoreGraphics
import Cocoa

protocol CaptureServiceDelegate: AnyObject {
    func captureService(didOutput image: CGImage)
}

class CaptureService: NSObject {
    private var stream: SCStream?
    private var streamOutput: StreamOutputHandler?
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
        super.init()
    }

    func startCapture() async {
        // 기존 로직: SCShareableContent, SCStream, 등등...
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)
            guard let display = content.displays.first else { return }

            let config = SCStreamConfiguration()
            config.width = display.width
            config.height = display.height
            config.pixelFormat = kCVPixelFormatType_32BGRA

            let filter = SCContentFilter(display: display, excludingWindows: [])
            stream = SCStream(filter: filter, configuration: config, delegate: nil)

            // ✅ appState를 넘겨서 output 핸들러 생성
            streamOutput = StreamOutputHandler(state: appState!)
            try stream?.addStreamOutput(streamOutput!, type: .screen, sampleHandlerQueue: .main)

            try await stream?.startCapture()
            print("✅ 캡처 스트림 시작됨")

        } catch {
            print("❌ 스트림 시작 실패: \(error)")
        }
    }

    func stopCapture() {
        Task {
            try? await stream?.stopCapture()
        }
    }
}
