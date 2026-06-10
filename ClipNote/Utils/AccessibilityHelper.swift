import AppKit
import ApplicationServices

class AccessibilityHelper {
    static func isAccessibilityEnabled() -> Bool {
        AXIsProcessTrusted()
    }
    
    static func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
    
    static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    @discardableResult
    static func showAccessibilityAlert() -> Bool {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = """
        ClipNote 需要辅助功能权限才能将内容粘贴到其他应用。
        
        如果已经启用但仍看到此提示，请先退出 ClipNote，在列表中删除旧的 ClipNote 条目，然后重新添加当前正在运行的 ClipNote。
        """
        alert.addButton(withTitle: "打开系统偏好设置")
        alert.addButton(withTitle: "稍后设置")
        
        let shouldOpenSettings = alert.runModal() == .alertFirstButtonReturn
        if shouldOpenSettings {
            openAccessibilitySettings()
            requestAccessibility()
        }
        return shouldOpenSettings
    }
}
