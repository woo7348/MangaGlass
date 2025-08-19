//
//  MangaGlassApp.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import SwiftUI

@main
struct MangaGlassApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TranslationWindowView(appState: appDelegate.appState)
                .frame(width: 300, height: 400)
        }
    }
}
