//
//  RegionDragCapture.swift
//  MangaGlass
//
//  Created by 강민우 on 8/22/25.
//

import AppKit
import CoreGraphics

// 퍼블릭 API: 전체 화면에 드래그 캡처 오버레이를 띄우고 완료 시 이미지를 돌려줍니다.
final class RegionDragCapture {
    static let shared = RegionDragCapture()

    // 각 디스플레이마다 1개씩 띄우는 캡처 창
    fileprivate var windows: [CaptureWindow] = []
    private var onComplete: ((NSImage?) -> Void)?

    func begin(_ completion: @escaping (NSImage?) -> Void) {
        onComplete = completion
        for screen in NSScreen.screens {
            let w = CaptureWindow(screen: screen, session: self)
            windows.append(w)
            w.makeKeyAndOrderFront(nil)
        }
        NSCursor.crosshair.set()
    }

    fileprivate func finish(with image: NSImage?) {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
        NSCursor.arrow.set()
        onComplete?(image)
        onComplete = nil
    }

    // 정확 캡처: 오버레이를 잠시 투명화 → 픽셀 좌표 integral/클램프 → Y축 반전 → CGImage 스냅샷
    fileprivate func snapshot(from screen: NSScreen, rectInScreenPts: CGRect) -> NSImage? {
        // 1) 드래그 오버레이 잠시 투명화(캡처에 섞이지 않게)
        let prevAlphas = windows.map { $0.alphaValue }
        for w in windows { w.alphaValue = 0.0 }
        NSApp.windows.forEach { $0.displayIfNeeded() } // 즉시 반영

        defer {
            // 복구(바로 finish()로 닫는 흐름이어도 안전하게 복구)
            for (i, w) in windows.enumerated() where i < prevAlphas.count {
                w.alphaValue = prevAlphas[i]
            }
        }

        // 2) 포인트 → 픽셀 (+ integral)
        let scale = screen.backingScaleFactor
        var pixelRect = CGRect(
            x: rectInScreenPts.origin.x * scale,
            y: rectInScreenPts.origin.y * scale,
            width: rectInScreenPts.size.width * scale,
            height: rectInScreenPts.size.height * scale
        ).integral

        // 3) 디스플레이 경계 클램프 + Y축 반전(디스플레이 원점은 좌상단)
        guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return nil
        }
        let displayBounds = CGDisplayBounds(displayID) // 픽셀 단위 (x:0, y:0, origin 상단)
        pixelRect = pixelRect.intersection(displayBounds)
        guard !pixelRect.isNull, pixelRect.width >= 2, pixelRect.height >= 2 else {
            return nil
        }

        var flipped = pixelRect
        flipped.origin.y = displayBounds.height - pixelRect.origin.y - pixelRect.height

        // 4) 디스플레이별 부분 캡처 (✅ 최신 문법)
        guard let cg = CGDisplayCreateImage(displayID, rect: flipped) else { return nil }

        // 5) 리샘플링 없이 NSImage 구성(픽셀 그대로 → OCR 품질 유지)
        let rep = NSBitmapImageRep(cgImage: cg)
        let image = NSImage(size: NSSize(width: rep.pixelsWide, height: rep.pixelsHigh))
        image.addRepresentation(rep)
        return image
    }
}

// MARK: - 캡처 윈도우
fileprivate final class CaptureWindow: NSWindow {
    private weak var session: RegionDragCapture?
    private let selectionView = SelectionView()

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(screen: NSScreen, session: RegionDragCapture) {
        self.session = session

        // 지정 이니셜라이저만 사용
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.setFrame(screen.frame, display: true)

        isOpaque = false
        backgroundColor = .clear
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        hasShadow = false
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]

        contentView = selectionView

        selectionView.onCancel = { [weak self] in
            self?.session?.finish(with: nil)
        }
        selectionView.onFinished = { [weak self] rectInWindow in
            guard let self, let session = self.session, let screen = self.screen else {
                self?.session?.finish(with: nil); return
            }
            // 창 좌표(포인트) → 스크린 좌표(포인트)
            let rectPts = self.convertToScreen(rectInWindow)
            // 오버레이 숨기고 고정밀 스냅샷
            let nsimg = session.snapshot(from: screen, rectInScreenPts: rectPts)
            session.finish(with: nsimg)
        }
    }
}

// MARK: - 드래그 선택 뷰
fileprivate final class SelectionView: NSView {
    var onFinished: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
        NSCursor.crosshair.set()
        needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53: onCancel?() // ESC
        case 36: // Enter
            if let r = selectionRect, r.width > 2, r.height > 2 { onFinished?(r) }
        default:
            super.keyDown(with: event)
        }
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentPoint = startPoint
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let r = selectionRect, r.width > 2, r.height > 2 else {
            onCancel?(); return
        }
        onFinished?(r)
    }

    private var selectionRect: CGRect? {
        guard let s = startPoint, let c = currentPoint else { return nil }
        return CGRect(
            x: min(s.x, c.x),
            y: min(s.y, c.y),
            width: abs(c.x - s.x),
            height: abs(c.y - s.y)
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 배경을 약간 어둡게 (필요 시 0.0로 조정)
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()

        // 선택 영역 펀칭 + 점선 테두리
        if let rect = selectionRect {
            NSGraphicsContext.current?.saveGraphicsState()
            NSBezierPath(rect: rect).addClip()
            NSColor.clear.set()
            rect.fill(using: .sourceOut)
            NSGraphicsContext.current?.restoreGraphicsState()

            NSColor.white.setStroke()
            let p = NSBezierPath(rect: rect)
            p.setLineDash([6, 3], count: 2, phase: 0)
            p.lineWidth = 2
            p.stroke()
        }

        // 힌트
        let tip = "드래그로 영역 선택 • Enter 캡처 • Esc 취소"
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 13, weight: .medium)
        ]
        tip.draw(at: CGPoint(x: 16, y: 16), withAttributes: attrs)
    }
}
