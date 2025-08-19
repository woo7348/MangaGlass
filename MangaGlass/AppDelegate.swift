import Cocoa
import ScreenCaptureKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlay1: GlassOverlayWindow!
    var statusBarController: StatusBarController?
    var appState = AppState()
    var translationWindowController: TranslationWindowController?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let translationWindow = TranslationWindowController(appState: appState)
        translationWindow.showWindow(nil)

        // 화면 중앙 기준 초기 프레임 계산
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let savedFrame = UserDefaults.standard.string(forKey: "OverlayWindowFrame").flatMap { NSRectFromString($0) }
        let initialRect = savedFrame ?? NSRect(
            x: screenFrame.midX - 300,
            y: screenFrame.midY - 200,
            width: 600,
            height: 400
        )

        // Overlay 1: 캡처 영역 지정
        overlay1 = GlassOverlayWindow(contentRect: initialRect, overlayID: "1", appState: appState)
        overlay1.makeKeyAndOrderFront(nil)

        // 상태 반영
        appState.overlayFrame = initialRect

        // 프레임 이동 감지 → overlayFrame 업데이트
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: overlay1,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.appState.overlayFrame = self.overlay1.frame
        }

        // 크기 조정 감지 → overlayFrame 업데이트
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: overlay1,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.appState.overlayFrame = self.overlay1.frame
        }

        print("✅ Overlay 1 생성 완료")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 프레임 저장
        let frameString = NSStringFromRect(appState.overlayFrame)
        UserDefaults.standard.set(frameString, forKey: "OverlayWindowFrame")
    }
}
