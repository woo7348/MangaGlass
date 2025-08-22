//
//  MenuBarController.swift
//  MangaGlass
//
//  Created by 강민우 on 8/22/25.
//

import AppKit
import SwiftUI

final class MenuBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()

    init() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "MangaGlass")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover.behavior = .transient
        popover.contentSize = NSSize(width: 240, height: 200)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: PopoverContentView())
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

struct PopoverContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MangaGlass").font(.headline)
            Divider()
            Button {
                WindowManager.shared.showTranslationWindow()
            } label: { Label("Open Main Window", systemImage: "macwindow") }

            Button {
                WindowManager.shared.showOverlay()
            } label: { Label("Show Overlay", systemImage: "rectangle.dashed") }

            Button {
                WindowManager.shared.hideOverlay()
            } label: { Label("Hide Overlay", systemImage: "eye.slash") }

            Spacer()
        }
        .padding(12)
        .frame(width: 220, height: 180)
    }
}
