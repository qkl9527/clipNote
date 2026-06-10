import Cocoa
import Combine
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panelManager: PanelManager?
    private let settingsWindowManager = SettingsWindowManager.shared
    private var cancellables = Set<AnyCancellable>()
    private let showInDockKey = "showInDock"
    private let showInMenuBarKey = "showInMenuBar"

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerDefaultSettings()
        panelManager = PanelManager.shared
        applyDockVisibility()
        applyStatusItemVisibility()
        setupGlobalHotkey()
        setupSettingsObservers()

        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.panelManager?.showPanel()
        }
        #endif
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        panelManager?.showPanel()
        return false
    }

    private func registerDefaultSettings() {
        UserDefaults.standard.register(defaults: [
            showInDockKey: false,
            showInMenuBarKey: true
        ])
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = makeStatusBarIcon()
            button.imagePosition = .imageOnly
            button.toolTip = "ClipNote"
        }

        let menu = NSMenu()

        let showItem = NSMenuItem(title: "显示全部 (⌥⌘V)", action: #selector(showPanel), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        // 最近复制记录（动态更新）
        updateRecentItems(menu: menu)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func removeStatusItem() {
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }

    private func applyStatusItemVisibility() {
        let shouldShow = UserDefaults.standard.bool(forKey: showInMenuBarKey)

        if shouldShow {
            if statusItem == nil {
                setupStatusItem()
            }
        } else {
            removeStatusItem()
        }
    }

    private func applyDockVisibility() {
        let shouldShow = UserDefaults.standard.bool(forKey: showInDockKey)
        NSApp.setActivationPolicy(shouldShow ? .regular : .accessory)
    }

    private func setupSettingsObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openSettings),
            name: .clipNoteOpenSettings,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetPanelSize),
            name: .clipNoteResetPanelSize,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    private func makeStatusBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()
        NSColor.black.setFill()

        let boardPath = NSBezierPath(roundedRect: NSRect(x: 4, y: 2, width: 10, height: 13), xRadius: 2, yRadius: 2)
        boardPath.fill()

        NSColor.white.setFill()
        let paperPath = NSBezierPath(roundedRect: NSRect(x: 5.5, y: 3.5, width: 7, height: 9.5), xRadius: 1.2, yRadius: 1.2)
        paperPath.fill()

        NSColor.black.setFill()
        let clipPath = NSBezierPath(roundedRect: NSRect(x: 6.5, y: 13, width: 5, height: 3), xRadius: 1.4, yRadius: 1.4)
        clipPath.fill()

        let checkPath = NSBezierPath()
        checkPath.lineWidth = 1.8
        checkPath.lineCapStyle = .round
        checkPath.lineJoinStyle = .round
        checkPath.move(to: NSPoint(x: 6.5, y: 8))
        checkPath.line(to: NSPoint(x: 8.5, y: 6))
        checkPath.line(to: NSPoint(x: 12, y: 10))
        checkPath.stroke()

        image.unlockFocus()
        image.isTemplate = true
        image.accessibilityDescription = "ClipNote"
        return image
    }

    private func updateRecentItems(menu: NSMenu) {
        // 添加最近5条记录
        let storage = StorageManager.shared
        let recentItems = storage.fetchRecent(limit: 5)

        for item in recentItems {
            let menuItem = NSMenuItem(title: "\(item.category.icon) \(item.previewText(maxLines: 1))", action: #selector(pasteItem(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = item
            menu.addItem(menuItem)
        }
    }

    @objc private func showPanel() {
        panelManager?.togglePanel()
    }

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowManager.show()
    }

    @objc private func settingsDidChange() {
        applyDockVisibility()
        applyStatusItemVisibility()
    }

    @objc private func resetPanelSize() {
        panelManager?.resetPanelSize()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    @objc private func pasteItem(_ sender: NSMenuItem) {
        if let item = sender.representedObject as? ClipItem {
            PasteService.shared.pasteToActiveApp(item: item)
        }
    }

    private func setupGlobalHotkey() {
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [weak self] in
            self?.panelManager?.togglePanel()
        }
    }
}

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel", default: .init(.v, modifiers: [.option, .command]))
}

extension Notification.Name {
    static let clipNoteOpenSettings = Notification.Name("clipNoteOpenSettings")
    static let clipNoteResetPanelSize = Notification.Name("clipNoteResetPanelSize")
}
