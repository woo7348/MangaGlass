import Cocoa
// import ScreenCaptureKit   // 더 이상 쓰지 않아 제거.

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var appState = AppState()
    var translationWindowController: TranslationWindowController?

    // 유지할 Overlay
    private var overlayWindow: GlassOverlayWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // StatusBarController 생성 시, overlay 제어 클로저 전달
        statusBarController = StatusBarController(
            onOpenMainWindow: { [weak self] in self?.showTranslationWindow() },
            onDragCapture: { [weak self] in
                self?.appState.captureByDragAndTranslate()
                self?.showTranslationWindow()
            },
            onShowOverlay: { [weak self] in self?.showOverlay() },
            onHideOverlay: { [weak self] in self?.hideOverlay() }
        )

        // (선택) 처음엔 메인 창만 띄우고, overlay는 팝오버에서 사용자가 켜도록
        showTranslationWindow()
    }

    // MARK: - Overlay 제어
    private func showOverlay() {
        if let overlay = overlayWindow {
            overlay.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // 최초 생성 시 위치/크기 복원
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let saved = UserDefaults.standard.string(forKey: "OverlayWindowFrame").flatMap { NSRectFromString($0) }
        let initialRect = saved ?? NSRect(x: screenFrame.midX - 300, y: screenFrame.midY - 200, width: 600, height: 400)

        let overlay = GlassOverlayWindow(contentRect: initialRect, overlayID: "1", appState: appState)
        overlay.isReleasedWhenClosed = false
        overlay.delegate = self   // 프레임 저장 원하면 아래 delegate 구현 추가
        overlay.makeKeyAndOrderFront(nil)

        overlayWindow = overlay
        appState.overlayFrame = initialRect

        // 이동/리사이즈 시 상태 반영(필요 시)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOverlayDidMoveOrResize), name: NSWindow.didMoveNotification, object: overlay)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOverlayDidMoveOrResize), name: NSWindow.didResizeNotification, object: overlay)
    }

    private func hideOverlay() {
        overlayWindow?.orderOut(nil)   // 완전 해제하려면 close() + overlayWindow = nil
        // overlayWindow?.close()
        // overlayWindow = nil
    }

    @objc private func handleOverlayDidMoveOrResize() {
        guard let overlay = overlayWindow else { return }
        appState.overlayFrame = overlay.frame
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 프레임 저장
        if let frame = overlayWindow?.frame ?? (appState.overlayFrame == .zero ? nil : appState.overlayFrame) {
            let s = NSStringFromRect(frame)
            UserDefaults.standard.set(s, forKey: "OverlayWindowFrame")
        }
    }

    // MARK: - 메인 번역 창
    private func showTranslationWindow() {
        if let wc = translationWindowController {
            wc.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let wc = TranslationWindowController(appState: appState)
        wc.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        translationWindowController = wc
    }
}

// (선택) 창 닫힘 처리로 레퍼런스 정리하고 싶다면
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let win = notification.object as? GlassOverlayWindow, win == overlayWindow {
            overlayWindow = nil
        }
    }
}
