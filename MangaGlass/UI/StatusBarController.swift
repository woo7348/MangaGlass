import AppKit
import SwiftUI

final class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var appState: AppState

    init(appState: AppState) {
        self.appState = appState

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 500, height: 500)
        popover.behavior = .transient
        self.popover = popover

        let translationWindow = TranslationWindowController(appState: appState)
        translationWindow.showWindow(nil)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "character.book.closed", accessibilityDescription: "MangaGlass")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
