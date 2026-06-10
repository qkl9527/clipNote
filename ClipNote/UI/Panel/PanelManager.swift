import Foundation
import Combine

/// 面板管理器 - 管理浮动面板的生命周期
class PanelManager {
    static let shared = PanelManager()
    
    private let panel: FloatingPanel
    private var clipboardManager: ClipboardManager?
    
    private init() {
        panel = FloatingPanel.shared
        setupClipboardManager()
    }
    
    private func setupClipboardManager() {
        clipboardManager = .shared
        clipboardManager?.startMonitoring()
    }
    
    /// 切换面板显示状态
    func togglePanel() {
        panel.toggle()
        
        if panel.isVisible {
            // 面板显示时，确保剪贴板管理器正在监听
            clipboardManager?.startMonitoring()
        }
    }
    
    /// 显示面板
    func showPanel() {
        panel.show()
        clipboardManager?.startMonitoring()
    }
    
    /// 隐藏面板
    func hidePanel() {
        panel.hide()
    }
    
    /// 获取剪贴板管理器
    func getClipboardManager() -> ClipboardManager? {
        return clipboardManager
    }
}
