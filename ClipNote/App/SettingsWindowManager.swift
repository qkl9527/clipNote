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
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ClipNote 设置"
        window.contentView = NSHostingView(rootView: view)
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 680, height: 480)
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
