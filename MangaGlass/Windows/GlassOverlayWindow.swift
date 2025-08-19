//
//  GlassOverlayWindow.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import Cocoa
import SwiftUI

class GlassOverlayWindow: NSWindow {
    let overlayID: String

    init(contentRect: NSRect, overlayID: String, appState: AppState) {
        self.overlayID = overlayID
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .resizable, .closable, .miniaturizable], // 이동 및 크기 조절 가능
            backing: .buffered,
            defer: false
        )

        // 창 기본 속성
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // 타이틀 표시 (Overlay1)
        self.title = "Overlay For Capture"
        self.titleVisibility = .visible
        self.titlebarAppearsTransparent = false
        self.isMovableByWindowBackground = true

        // OverlayView 설정
        let contentView = OverlayView(appState: appState, overlayID: overlayID)
        self.contentView = NSHostingView(rootView: contentView)
    }

    // 창 드래그 시 강제 리프레시 (잔상 최소화 목적)
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        self.displayIfNeeded()
    }
}
