//
//  WindowManager.swift
//  MangaGlass
//
//  Created by 강민우 on 8/22/25.
//

import AppKit
import SwiftUI

final class WindowManager: NSObject, NSWindowDelegate {
    static let shared = WindowManager()

    private var translationWindow: NSWindow?
    private var overlayWindow: NSWindow?

    // MARK: - Translation(Main) Window
    func showTranslationWindow() {
        if let win = translationWindow {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        // SwiftUI 루트 뷰로 교체하세요
        let rootView = TranslationWindowView(appState: AppState())
        let hosting = NSHostingController(rootView: rootView)

        let win = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 380, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        win.title = "MangaGlass"
        win.contentViewController = hosting
        win.isReleasedWhenClosed = false        // 닫아도 메모리에서 안 날아가게
        win.delegate = self
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        translationWindow = win
    }

    func closeTranslationWindow() {
        translationWindow?.close()
        // isReleasedWhenClosed=false 이면 close 후에도 인스턴스는 남습니다.
        // 완전히 해제 원하면 아래 줄 주석 해제
        // translationWindow = nil
    }

    // MARK: - Overlay Window (예: 영역 가이드/툴)
    func showOverlay() {
        if let w = overlayWindow {
            w.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let overlay = NSWindow(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless],
            backing: .buffered, defer: false)
        overlay.isOpaque = false
        overlay.backgroundColor = NSColor.black.withAlphaComponent(0.15)
        overlay.level = .screenSaver
        overlay.ignoresMouseEvents = false
        overlay.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlay.isReleasedWhenClosed = false     // 재사용 가능
        overlay.delegate = self

        // 간단한 닫기 버튼(옵션)
        let closeButton = NSButton(title: "Close Overlay", target: self, action: #selector(hideOverlayAction))
        closeButton.bezelStyle = .rounded
        let hosting = NSHostingView(rootView:
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Close Overlay") { self.hideOverlay() }
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        overlay.contentView = hosting

        overlay.makeKeyAndOrderFront(nil)
        overlayWindow = overlay
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func hideOverlayAction() { hideOverlay() }

    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        // 완전 해제하려면:
        // overlayWindow?.close()
        // overlayWindow = nil
    }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        guard let win = notification.object as? NSWindow else { return }
        if win == translationWindow {
            // X 버튼으로 닫혔을 때 다시 만들 수 있게 하려면 레퍼런스를 nil로
            translationWindow = nil
        } else if win == overlayWindow {
            overlayWindow = nil
        }
    }
}
