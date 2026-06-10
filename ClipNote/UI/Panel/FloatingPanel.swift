import Cocoa
import SwiftUI

/// 浮动面板 - 类似 Spotlight 的浮动窗口
class FloatingPanel: NSPanel {
    static let shared = FloatingPanel()
    
    private var hostingView: NSHostingView<AnyView>?
    
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
        // 窗口属性
        title = "ClipNote"
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        level = .floating
        isReleasedWhenClosed = false
        
        // 窗口样式
        backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        isOpaque = false
        hasShadow = true
        
        // 圆角
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 12
        contentView?.layer?.masksToBounds = true
        
        // 设置内容视图
        let contentView = AnyView(
            ContentView()
                .environmentObject(ClipboardManager.shared)
        )
        hostingView = NSHostingView(rootView: contentView)
        self.contentView = hostingView
        
        // 默认隐藏
        orderOut(nil)
    }
    
    /// 显示面板
    func show() {
        guard !isVisible else { return }
        
        // 居中显示
        center()
        
        // 显示面板
        makeKeyAndOrderFront(nil)
        
        // 激活应用但不抢夺焦点
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// 隐藏面板
    func hide() {
        orderOut(nil)
    }
    
    /// 切换显示状态
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    /// 居中显示在屏幕
    func centerOnScreen() {
        guard let screen = NSScreen.main else { return }
        
        let screenFrame = screen.visibleFrame
        let panelFrame = frame
        
        let x = screenFrame.midX - panelFrame.width / 2
        let y = screenFrame.midY - panelFrame.height / 2
        
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
