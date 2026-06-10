import Cocoa
import SwiftUI

class FloatingPanel: NSPanel {
    static let shared = FloatingPanel()

    private var hostingView: NSHostingView<AnyView>?
    private let defaultSize = NSSize(width: 900, height: 400)
    private let minimumSize = NSSize(width: 640, height: 320)

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 400),
            styleMask: [.nonactivatingPanel, .titled, .closable, .resizable],
            backing: .buffered,
            defer: true
        )

        setupPanel()
    }

    private func setupPanel() {
        title = "ClipNote"
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = false
        level = .floating
        isReleasedWhenClosed = false
        minSize = minimumSize
        setContentSize(defaultSize)

        backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        isOpaque = false
        hasShadow = true

        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 12
        contentView?.layer?.masksToBounds = true

        let contentView = AnyView(
            ContentView()
                .environmentObject(ClipboardManager.shared)
        )
        hostingView = NSHostingView(rootView: contentView)
        self.contentView = hostingView

        orderOut(nil)
    }

    func show() {
        guard !isVisible else { return }

        PasteService.shared.rememberCurrentTargetApplication()
        center()

        makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        orderOut(nil)
    }

    func resetToDefaultSize() {
        setContentSize(defaultSize)
        center()
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func centerOnScreen() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let panelFrame = frame

        let x = screenFrame.midX - panelFrame.width / 2
        let y = screenFrame.midY - panelFrame.height / 2

        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
