//
//  TranslationWindowController.swift
//  MangaGlass
//
//  Created by 강민우 on 7/19/25.
//

import Cocoa
import SwiftUI

class TranslationWindowController: NSWindowController {

    init(appState: AppState) {
        let contentView = TranslationWindowView(appState: appState)
        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MangaGlass 번역 도구"
        window.contentView = hostingController.view
        window.center()

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// ✅ showWindow 메서드를 사용 가능하게 하기 위해 NSWindowController 상속 필수
}
