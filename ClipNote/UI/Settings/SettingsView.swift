import SwiftUI
import KeyboardShortcuts
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @AppStorage("maxItems") private var maxItems: Int = 100_000
    @AppStorage("pollingInterval") private var pollingInterval: Double = 0.5
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("showInDock") private var showInDock: Bool = false
    @AppStorage("showInMenuBar") private var showInMenuBar: Bool = true
    @AppStorage("defaultPanelWidth") private var defaultPanelWidth: Int = 900
    @AppStorage("defaultPanelHeight") private var defaultPanelHeight: Int = 430
    @AppStorage("showCategoryShortcuts") private var showCategoryShortcuts: Bool = true

    @State private var selectedSection: SettingsSection = .general
    @State private var isShowingClearConfirmation = false
    @State private var accessibilityGranted = PasteService.shared.checkAccessibility()
    @State private var defaultPanelWidthText = ""
    @State private var defaultPanelHeightText = ""

    var body: some View {
        HStack(spacing: 0) {
            sidebar

            Rectangle()
                .fill(ClipNoteTheme.hairline)
                .frame(width: 1)

            detail
        }
        .frame(width: 720, height: 520)
        .background(ClipNoteTheme.canvas)
        .alert("清空所有记录？", isPresented: $isShowingClearConfirmation) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                clipboardManager.storageManager.clearAll()
            }
        } message: {
            Text("此操作会永久删除当前保存的剪贴板记录，无法撤销。")
        }
        .onAppear {
            refreshAccessibility()
            defaultPanelWidthText = "\(defaultPanelWidth)"
            defaultPanelHeightText = "\(defaultPanelHeight)"
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                ClipNoteLogoView(size: 20)

                Text("ClipNote")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ClipNoteTheme.ink)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            ForEach(SettingsSection.allCases) { section in
                SettingsSidebarRow(
                    section: section,
                    isSelected: selectedSection == section
                ) {
                    selectedSection = section
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text("\(clipboardManager.clips.count) 条记录")
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.muted)

                Text("快捷键 ⌥⌘V")
                    .font(.caption2)
                    .foregroundColor(ClipNoteTheme.mutedSoft)
            }
            .padding(.horizontal, 12)
        }
        .padding(12)
        .frame(width: 176, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(ClipNoteTheme.surfaceSoft)
    }

    @ViewBuilder
    private var detail: some View {
        VStack(alignment: .leading, spacing: 0) {
            detailHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    switch selectedSection {
                    case .general:
                        generalSettings
                    case .shortcuts:
                        shortcutSettings
                    case .data:
                        dataSettings
                    case .permissions:
                        permissionSettings
                    case .about:
                        aboutView
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .background(ClipNoteTheme.canvas)
    }

    private var detailHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedSection.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ClipNoteTheme.ink)

                Text(selectedSection.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(ClipNoteTheme.muted)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(ClipNoteTheme.canvas)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ClipNoteTheme.hairlineSoft)
                .frame(height: 1)
        }
    }

    private var generalSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsGroup("基本设置") {
                SettingsToggleRow(title: "开机自启动", subtitle: "登录 macOS 后自动启动 ClipNote", isOn: $launchAtLogin)
                SettingsToggleRow(title: "在 Dock 中显示图标", subtitle: "需要把 ClipNote 当作普通窗口应用时开启", isOn: $showInDock)
                SettingsToggleRow(title: "在顶部任务栏显示图标", subtitle: "保留菜单栏入口，适合后台常驻使用", isOn: $showInMenuBar)
                SettingsToggleRow(title: "显示分类快捷键", subtitle: "在主窗口分类名称后显示 ⌘⌥数字", isOn: $showCategoryShortcuts)

                SettingsNumberRow(title: "默认窗口宽度", subtitle: "主窗口重置后的宽度", text: $defaultPanelWidthText, suffix: "px")
                SettingsNumberRow(title: "默认窗口高度", subtitle: "主窗口重置后的高度", text: $defaultPanelHeightText, suffix: "px")

                SettingsActionRow(title: "恢复默认窗口大小", subtitle: "将主面板恢复为 \(previewPanelWidth) x \(previewPanelHeight)") {
                    applyDefaultPanelSize()
                }
            }

            SettingsGroup("监听设置") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("轮询间隔")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(ClipNoteTheme.body)

                            Text("剪贴板变化检查频率")
                                .font(.caption)
                                .foregroundColor(ClipNoteTheme.muted)
                        }

                        Spacer()

                        Text(String(format: "%.1f 秒", pollingInterval))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(ClipNoteTheme.primaryActive)
                    }

                    Slider(value: $pollingInterval, in: 0.1...2.0, step: 0.1)
                        .tint(ClipNoteTheme.primary)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var shortcutSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsGroup("全局快捷键") {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("唤出面板")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ClipNoteTheme.body)

                        Text("从任意应用打开或隐藏 ClipNote")
                            .font(.caption)
                            .foregroundColor(ClipNoteTheme.muted)
                    }

                    Spacer()

                    KeyboardShortcuts.Recorder("", name: .togglePanel)
                        .frame(width: 150)
                }

                // SettingsToggleRow(title: "显示分类快捷键", subtitle: "在主窗口分类名称后显示 ⌘⌥数字", isOn: $showCategoryShortcuts)
            }

            SettingsGroup("快捷键说明") {
                VStack(spacing: 8) {
                    shortcutRow(keys: "⌥⌘V", description: "唤出/隐藏面板")
                    shortcutRow(keys: "⌘K", description: "清空搜索")
                    shortcutRow(keys: "⌘⌥0", description: "选择全部")
                    shortcutRow(keys: "⌘⌥1-9", description: "选择分类")
                    shortcutRow(keys: "Enter", description: "粘贴选中内容")
                    shortcutRow(keys: "⌘C", description: "复制到剪贴板")
                    shortcutRow(keys: "Esc", description: "关闭面板")
                    shortcutRow(keys: "← →", description: "切换选中卡片")
                }
            }
        }
    }

    private var dataSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsGroup("存储设置") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("最大保存条目数")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ClipNoteTheme.body)

                        Text("超过限制后会清理最早的记录")
                            .font(.caption)
                            .foregroundColor(ClipNoteTheme.muted)
                    }

                    Spacer()

                    TextField("", value: $maxItems, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 86)
                }
            }

            SettingsGroup("数据管理") {
                SettingsInfoRow(title: "当前条目数", value: "\(clipboardManager.clips.count)")

                SettingsActionRow(
                    title: "清空所有记录",
                    subtitle: "删除本机保存的剪贴板历史",
                    role: .destructive
                ) {
                    isShowingClearConfirmation = true
                }
            }

            SettingsGroup("导出") {
                SettingsActionRow(title: "导出为 JSON", subtitle: "将当前记录保存到本机文件") {
                    exportData()
                }
            }
        }
    }

    private var permissionSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsGroup("辅助功能权限") {
                HStack(spacing: 12) {
                    Image(systemName: accessibilityGranted ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(accessibilityGranted ? ClipNoteTheme.success : ClipNoteTheme.warning)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(accessibilityGranted ? "已授权" : "需要授权")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ClipNoteTheme.ink)

                        Text("用于将选中的剪贴板内容粘贴到当前应用")
                            .font(.caption)
                            .foregroundColor(ClipNoteTheme.muted)
                    }

                    Spacer()
                }
                .padding(.vertical, 2)

                HStack {
                    Button("打开系统设置") {
                        AccessibilityHelper.openAccessibilitySettings()
                        PasteService.shared.requestAccessibility()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ClipNoteTheme.primary)

                    Button("重新检查") {
                        refreshAccessibility()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 4)
            }

            SettingsGroup("检查项") {
                permissionRow(title: "监听剪贴板", granted: true)
                permissionRow(title: "写入剪贴板", granted: true)
                permissionRow(title: "模拟粘贴", granted: accessibilityGranted)
            }

            SettingsGroup("系统路径") {
                Text("系统设置 → 隐私与安全性 → 辅助功能")
                    .font(.system(size: 13))
                    .foregroundColor(ClipNoteTheme.body)
            }
        }
    }

    private var aboutView: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsGroup("应用信息") {
                HStack(spacing: 14) {
                    Image(nsImage: AppIconProvider.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 58, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("ClipNote")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(ClipNoteTheme.ink)

                        Text("v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(ClipNoteTheme.muted)

                        Text("轻量级 macOS 剪贴板管理工具")
                            .font(.system(size: 13))
                            .foregroundColor(ClipNoteTheme.body)
                    }
                }
            }

            SettingsGroup("详情") {
                SettingsInfoRow(title: "快捷键", value: "⌥⌘V")
                SettingsInfoRow(title: "存储位置", value: "本机 SQLite")
                SettingsInfoRow(title: "系统要求", value: "macOS 14+")
                SettingsInfoRow(title: "构建", value: "SwiftUI + AppKit")
            }

            SettingsGroup("项目") {
                SettingsExternalLinkRow(
                    title: "项目地址",
                    subtitle: "github.com/qkl9527/clipNote",
                    url: URL(string: "https://github.com/qkl9527/clipNote")!,
                    buttonText: "访问"
                )

                SettingsExternalLinkRow(
                    title: "问题反馈",
                    subtitle: "通过 GitHub Issues 提交问题和建议",
                    url: URL(string: "https://github.com/qkl9527/clipNote/issues")!,
                    buttonText: "反馈"
                )
            }

            SettingsGroup("隐私") {
                Text("剪贴板记录仅保存在本机。")
                    .font(.system(size: 13))
                    .foregroundColor(ClipNoteTheme.body)
            }
        }
    }

    private func shortcutRow(keys: String, description: String) -> some View {
        HStack(spacing: 10) {
            Text(keys)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(ClipNoteTheme.ink)
                .frame(width: 78, alignment: .center)
                .padding(.vertical, 4)
                .background(ClipNoteTheme.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(ClipNoteTheme.hairline, lineWidth: 1)
                )

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(ClipNoteTheme.body)

            Spacer()
        }
    }

    private func permissionRow(title: String, granted: Bool) -> some View {
        HStack {
            Image(systemName: granted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(granted ? ClipNoteTheme.success : ClipNoteTheme.mutedSoft)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(ClipNoteTheme.body)

            Spacer()
        }
    }

    private func refreshAccessibility() {
        accessibilityGranted = PasteService.shared.checkAccessibility()
    }

    private var previewPanelWidth: Int {
        normalizedPanelValue(defaultPanelWidthText, fallback: defaultPanelWidth, range: 300...1600)
    }

    private var previewPanelHeight: Int {
        normalizedPanelValue(defaultPanelHeightText, fallback: defaultPanelHeight, range: 260...1000)
    }

    private func applyDefaultPanelSize() {
        let width = previewPanelWidth
        let height = previewPanelHeight

        defaultPanelWidth = width
        defaultPanelHeight = height
        defaultPanelWidthText = "\(width)"
        defaultPanelHeightText = "\(height)"

        NotificationCenter.default.post(name: .clipNoteResetPanelSize, object: nil)
    }

    private func normalizedPanelValue(_ text: String, fallback: Int, range: ClosedRange<Int>) -> Int {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(trimmedText) else { return fallback }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "clipnote_export_\(Date().timeIntervalSince1970).json"
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    encoder.dateEncodingStrategy = .iso8601
                    
                    let data = try encoder.encode(clipboardManager.clips)
                    try data.write(to: url)
                } catch {
                    print("导出失败: \(error)")
                }
            }
        }
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case shortcuts
    case data
    case permissions
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "通用"
        case .shortcuts: return "快捷键"
        case .data: return "数据"
        case .permissions: return "权限"
        case .about: return "关于"
        }
    }

    var subtitle: String {
        switch self {
        case .general: return "启动方式、窗口和剪贴板监听偏好"
        case .shortcuts: return "全局唤出与面板内操作快捷键"
        case .data: return "存储上限、导出与清空记录"
        case .permissions: return "辅助功能授权和粘贴能力检查"
        case .about: return "版本、隐私和构建信息"
        }
    }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .shortcuts: return "keyboard"
        case .data: return "externaldrive"
        case .permissions: return "lock.shield"
        case .about: return "info.circle"
        }
    }
}

private struct SettingsSidebarRow: View {
    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 18)

                Text(section.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))

                Spacer()
            }
            .foregroundColor(isSelected ? .white : ClipNoteTheme.body)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? ClipNoteTheme.primary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ClipNoteTheme.muted)

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ClipNoteTheme.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ClipNoteTheme.hairline, lineWidth: 1)
            )
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ClipNoteTheme.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.muted)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ClipNoteTheme.primary)
        }
    }
}

private struct SettingsNumberRow: View {
    let title: String
    let subtitle: String
    @Binding var text: String
    let suffix: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ClipNoteTheme.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.muted)
            }

            Spacer()

            HStack(spacing: 6) {
                TextField("", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 82)

                Text(suffix)
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.muted)
            }
        }
    }
}

private struct SettingsActionRow: View {
    let title: String
    let subtitle: String
    var role: ButtonRole?
    let isDestructive: Bool
    let action: () -> Void

    init(title: String, subtitle: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.role = role
        self.isDestructive = role == .destructive
        self.action = action
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isDestructive ? ClipNoteTheme.error : ClipNoteTheme.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.muted)
            }

            Spacer()

            if isDestructive {
                Button("清空", role: role, action: action)
                    .buttonStyle(.bordered)
                    .tint(ClipNoteTheme.error)
            } else {
                Button("执行", role: role, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(ClipNoteTheme.primary)
            }
        }
    }
}

private struct SettingsExternalLinkRow: View {
    let title: String
    let subtitle: String
    let url: URL
    let buttonText: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ClipNoteTheme.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.muted)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Button(buttonText) {
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct SettingsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(ClipNoteTheme.body)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ClipNoteTheme.muted)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ClipboardManager())
}
