//
//  DragCaptureService.swift
//  MangaGlass
//
//  Created by 강민우 on 8/18/25.
//

import AppKit
import CoreGraphics

// MARK: - 퍼블릭: 드래그 캡처 시작 API
final class RegionCaptureSession: NSObject {
    static let shared = RegionCaptureSession()

    private var windows: [RegionCaptureWindow] = []
    private var onComplete: ((NSImage?) -> Void)?

    /// 전체 화면에 반투명 오버레이를 띄우고, 드래그 영역을 캡처합니다.
    func beginCapture(_ completion: @escaping (NSImage?) -> Void) {
        self.onComplete = completion
        createWindowsForAllScreens()
    }

    fileprivate func finish(with image: NSImage?) {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
        onComplete?(image)
        onComplete = nil
    }

    private func createWindowsForAllScreens() {
        for screen in NSScreen.screens {
            let w = RegionCaptureWindow(screen: screen, delegate: self)
            windows.append(w)
            w.makeKeyAndOrderFront(nil)
        }
        NSCursor.crosshair.set()
    }
}

// MARK: - 내부: 선택 창
fileprivate final class RegionCaptureWindow: NSWindow {
    private let selectionView: SelectionView
    private weak var sessionDelegate: RegionCaptureSession?

    init(screen: NSScreen, delegate: RegionCaptureSession) {
        self.selectionView = SelectionView()
        self.sessionDelegate = delegate

        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        isOpaque = false
        backgroundColor = NSColor.black.withAlphaComponent(0.25)
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        hasShadow = false
        level = .screenSaver  // 최상위
        collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces, .transient]

        contentView = selectionView
        selectionView.onCancel = { [weak self] in self?.cancel() }
        selectionView.onFinished = { [weak self] rectInWindow in
            self?.capture(rectInWindow: rectInWindow)
        }
    }

    private func cancel() {
        sessionDelegate?.finish(with: nil)
    }

    private func capture(rectInWindow: CGRect) {
        // 윈도우 좌표 → 스크린 좌표 변환
        let rectInScreen = convertToScreen(rectInWindow)
        // 스크린 좌표 → 글로벌(전체) 좌표는 동일하게 취급 가능 (같은 스크린 내라면)
        // 다중 모니터에서도 convertToScreen이 올바른 global rect를 돌려준다.

        if let cgImage = CGWindowListCreateImage(
            rectInScreen,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        ) {
            let nsImage = NSImage(cgImage: cgImage, size: rectInScreen.size)
            sessionDelegate?.finish(with: nsImage)
        } else {
            sessionDelegate?.finish(with: nil)
        }
    }
}

// MARK: - 내부: 드래그 선택 뷰
fileprivate final class SelectionView: NSView {
    var onFinished: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var isDragging = false

    override var acceptsFirstResponder: Bool { true }

    // 키 이벤트 (ESC 취소 / Return 캡처)
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53: // Esc
            onCancel?()
        case 36: // Return
            if let rect = selectionRect { onFinished?(rect) }
        default:
            super.keyDown(with: event)
        }
    }

    // 마우스 드래그로 사각형 선택
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        isDragging = true
        startPoint = event.locationInWindow
        currentPoint = startPoint
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        isDragging = false
        currentPoint = event.locationInWindow
        if let rect = selectionRect, rect.width > 2, rect.height > 2 {
            onFinished?(rect)
        } else {
            onCancel?()
        }
    }

    private var selectionRect: CGRect? {
        guard let s = startPoint, let c = currentPoint else { return nil }
        let rect = CGRect(
            x: min(s.x, c.x),
            y: min(s.y, c.y),
            width: abs(c.x - s.x),
            height: abs(c.y - s.y)
        )
        return rect
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 화면 전체를 어둡게
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()

        // 선택 영역은 밝게 마스킹
        if let rect = selectionRect {
            NSColor.clear.setFill()
            let path = NSBezierPath(rect: rect)
            NSGraphicsContext.current?.saveGraphicsState()
            path.addClip()
            NSColor.clear.set()
            rect.fill(using: .sourceOut)
            NSGraphicsContext.current?.restoreGraphicsState()

            // 선택 테두리
            NSColor.white.setStroke()
            NSBezierPath(rect: rect).setLineDash([5,3], count: 2, phase: 0)
            NSBezierPath(rect: rect).lineWidth = 2
            NSBezierPath(rect: rect).stroke()
        }

        // 안내 텍스트
        let tip = "드래그해서 영역 선택 • Enter 캡처 • Esc 취소"
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .shadow: {
                let s = NSShadow()
                s.shadowBlurRadius = 3
                s.shadowOffset = .init(width: 0, height: -1)
                s.shadowColor = .black
                return s
            }()
        ]
        let size = tip.size(withAttributes: attrs)
        tip.draw(
            at: CGPoint(x: 16, y: 16),
            withAttributes: attrs
        )
    }
}
