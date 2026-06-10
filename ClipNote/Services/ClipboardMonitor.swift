import Foundation
import AppKit
import Combine

/// 剪贴板监听器
class ClipboardMonitor: ObservableObject {
    @Published var latestItem: ClipItem?
    @Published var isMonitoring = false

    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    private var timer: Timer?
    private let storageManager: StorageManager
    private let contentAnalyzer: ContentAnalyzer
    private let processingQueue = DispatchQueue(label: "com.clipnote.clipboard-processing", qos: .utility)
    private var pendingChangeCount: Int?

    private let pollingInterval: TimeInterval = 0.5

    init(storageManager: StorageManager = .shared, contentAnalyzer: ContentAnalyzer = .shared) {
        self.storageManager = storageManager
        self.contentAnalyzer = contentAnalyzer
        self.changeCount = pasteboard.changeCount
    }

    deinit {
        stopMonitoring()
    }

    /// 开始监听剪贴板
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        changeCount = pasteboard.changeCount

        timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }

        RunLoop.main.add(timer!, forMode: .common)
    }

    /// 停止监听
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    /// 检查剪贴板变化
    private func checkForChanges() {
        let currentChangeCount = pasteboard.changeCount
        guard currentChangeCount != changeCount else { return }

        changeCount = currentChangeCount
        processClipboardContent(changeCount: currentChangeCount)
    }

    /// 处理剪贴板内容
    private func processClipboardContent(changeCount: Int) {
        guard let items = pasteboard.pasteboardItems, !items.isEmpty else { return }
        let sourceAppName = getCurrentAppName()
        let sourceBundleId = getCurrentAppBundleId()

        pendingChangeCount = changeCount
        let filteredItems = items.filter { item in
            !isSensitiveContent(item: item, sourceBundleId: sourceBundleId)
        }

        processingQueue.async { [weak self] in
            guard let self else { return }

            autoreleasepool {
                for item in filteredItems {
                    if let clipItem = self.contentAnalyzer.analyze(item: item, sourceApp: sourceAppName, sourceBundleId: sourceBundleId) {
                        self.storageManager.save(clipItem)

                        DispatchQueue.main.async { [weak self] in
                            guard self?.pendingChangeCount == changeCount else { return }
                            self?.latestItem = clipItem
                        }
                        break
                    }
                }
            }
        }
    }

    /// 检查是否为敏感内容（密码管理器等）
    private func isSensitiveContent(item: NSPasteboardItem, sourceBundleId: String?) -> Bool {
        // 检查 org.nspasteboard.ConcealedType
        if let concealedData = item.data(forType: NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")),
           let concealed = String(data: concealedData, encoding: .utf8),
           concealed == "true" {
            return true
        }

        // 检查来源应用是否为密码管理器
        let passwordApps = [
            "com.1password.1password",
            "com.agilebits.onepassword7",
            "com.bitwarden.desktop",
            "com.lastpass.LastPass",
            "com.dashlane.Dashlane"
        ]

        if let sourceApp = sourceBundleId, passwordApps.contains(sourceApp) {
            return true
        }

        return false
    }

    /// 获取当前应用名称
    private func getCurrentAppName() -> String? {
        NSWorkspace.shared.frontmostApplication?.localizedName
    }

    /// 获取当前应用 Bundle ID
    private func getCurrentAppBundleId() -> String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }
}
