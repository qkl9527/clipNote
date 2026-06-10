import AppKit
import SwiftUI

final class SettingsWindowManager {
    static let shared = SettingsWindowManager()

    private var window: NSWindow?

    private init() {}

    func show() {
        if let window {
            bringToFront(window)
            return
        }

        let view = SettingsView()
            .environmentObject(ClipboardManager.shared)
            .environmentObject(StorageManager.shared)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ClipNote 设置"
        window.contentView = NSHostingView(rootView: view)
        window.isReleasedWhenClosed = false
        window.level = .modalPanel
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.center()

        self.window = window
        bringToFront(window)
    }

    private func bringToFront(_ window: NSWindow) {
        window.level = .modalPanel
        window.deminiaturize(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
