//import AppKit
//import SwiftUI
//
//final class StatusBarController {
//    private var statusItem: NSStatusItem
//    private var popover: NSPopover
//    private var appState: AppState
//
//    init(appState: AppState) {
//        self.appState = appState
//
//        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//        
//        let popover = NSPopover()
//        popover.contentSize = NSSize(width: 500, height: 500)
//        popover.behavior = .transient
//        self.popover = popover
//
//        let translationWindow = TranslationWindowController(appState: appState)
//        translationWindow.showWindow(nil)
//        
//        if let button = statusItem.button {
//            button.image = NSImage(systemSymbolName: "character.book.closed", accessibilityDescription: "MangaGlass")
//            button.action = #selector(togglePopover(_:))
//            button.target = self
//        }
//    }
//
//    @objc private func togglePopover(_ sender: AnyObject?) {
//        guard let button = statusItem.button else { return }
//
//        if popover.isShown {
//            popover.performClose(sender)
//        } else {
//            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
//        }
//    }
//}

import AppKit
import SwiftUI

final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()

    private let onOpenMainWindow: () -> Void
    private let onDragCapture: () -> Void
    private let onShowOverlay: () -> Void
    private let onHideOverlay: () -> Void

    init(onOpenMainWindow: @escaping () -> Void,
         onDragCapture: @escaping () -> Void,
         onShowOverlay: @escaping () -> Void,
         onHideOverlay: @escaping () -> Void) {

        self.onOpenMainWindow = onOpenMainWindow
        self.onDragCapture   = onDragCapture
        self.onShowOverlay   = onShowOverlay
        self.onHideOverlay   = onHideOverlay

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "MangaGlass")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover.behavior = .transient
        popover.contentSize = NSSize(width: 240, height: 220)
        popover.contentViewController = NSViewController()

        // 버튼 누르면 팝오버 닫고 액션 실행
        let root = PopoverView(
            onOpenMainWindow: { [weak self] in
                guard let self else { return }
                self.popover.performClose(nil)
                self.onOpenMainWindow()
            },
            onDragCapture: { [weak self] in
                guard let self else { return }
                self.popover.performClose(nil)
                self.onDragCapture()
            },
            onShowOverlay: { [weak self] in
                guard let self else { return }
                self.popover.performClose(nil)
                self.onShowOverlay()
            },
            onHideOverlay: { [weak self] in
                guard let self else { return }
                self.popover.performClose(nil)
                self.onHideOverlay()
            }
        )
        popover.contentViewController?.view = NSHostingView(rootView: root)
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

struct PopoverView: View {
    let onOpenMainWindow: () -> Void
    let onDragCapture: () -> Void
    let onShowOverlay: () -> Void
    let onHideOverlay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MangaGlass").font(.headline)
            Divider()

            Button { onOpenMainWindow() } label: {
                Label("메인 창 열기", systemImage: "macwindow")
            }

            Button { onDragCapture() } label: {
                Label("영역 선택 후 번역", systemImage: "selection.pin.in.out")
            }

            Divider()

            Button { onShowOverlay() } label: {
                Label("Overlay 표시", systemImage: "rectangle.dashed")
            }
            Button { onHideOverlay() } label: {
                Label("Overlay 숨기기", systemImage: "eye.slash")
            }

            Spacer()
        }
        .padding(12)
        .frame(width: 220, height: 200)
    }
}
