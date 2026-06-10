import SwiftUI
import KeyboardShortcuts

/// 设置页面
struct SettingsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @AppStorage("maxItems") private var maxItems: Int = 1000
    @AppStorage("pollingInterval") private var pollingInterval: Double = 0.5
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("showInDock") private var showInDock: Bool = false
    @AppStorage("showInMenuBar") private var showInMenuBar: Bool = true
    
    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("通用", systemImage: "gear")
                }
            
            shortcutSettings
                .tabItem {
                    Label("快捷键", systemImage: "keyboard")
                }
            
            dataSettings
                .tabItem {
                    Label("数据", systemImage: "externaldrive")
                }
            
            aboutView
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
    
    private var generalSettings: some View {
        Form {
            Section("基本设置") {
                Toggle("开机自启动", isOn: $launchAtLogin)
                Toggle("在 Dock 中显示图标", isOn: $showInDock)
                Toggle("在顶部任务栏显示图标", isOn: $showInMenuBar)
                Button("恢复默认窗口大小") {
                    NotificationCenter.default.post(name: .clipNoteResetPanelSize, object: nil)
                }
            }
            
            Section("监听设置") {
                HStack {
                    Text("轮询间隔")
                    Slider(value: $pollingInterval, in: 0.1...2.0, step: 0.1)
                    Text(String(format: "%.1f 秒", pollingInterval))
                        .frame(width: 50)
                }
            }
            
            Section("辅助功能权限") {
                HStack {
                    Text("Accessibility 权限")
                    Spacer()
                    if PasteService.shared.checkAccessibility() {
                        Text("已授权")
                            .foregroundColor(.green)
                    } else {
                        Button("授权") {
                            PasteService.shared.requestAccessibility()
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private var shortcutSettings: some View {
        Form {
            Section("全局快捷键") {
                KeyboardShortcuts.Recorder("唤出面板:", name: .togglePanel)
            }
            
            Section("快捷键说明") {
                VStack(alignment: .leading, spacing: 8) {
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
        .padding()
    }
    
    private var dataSettings: some View {
        Form {
            Section("存储设置") {
                HStack {
                    Text("最大保存条目数")
                    Spacer()
                    TextField("", value: $maxItems, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
            }
            
            Section("数据管理") {
                HStack {
                    Text("当前条目数")
                    Spacer()
                    Text("\(clipboardManager.clips.count)")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    clipboardManager.storageManager.clearAll()
                }) {
                    Text("清空所有记录")
                        .foregroundColor(.red)
                }
            }
            
            Section("导出") {
                Button(action: exportData) {
                    Text("导出为 JSON")
                }
            }
        }
        .padding()
    }
    
    private var aboutView: some View {
        VStack(spacing: 16) {
            Image(nsImage: AppIconProvider.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
            
            Text("ClipNote")
                .font(.title)
                .fontWeight(.bold)
            
            Text("v1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("轻量级 macOS 剪贴板管理工具")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("快捷键: ⌥⌘V 唤出面板")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func shortcutRow(keys: String, description: String) -> some View {
        HStack {
            Text(keys)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(nsColor: .separatorColor))
                .cornerRadius(4)
            
            Text(description)
                .font(.body)
        }
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

#Preview {
    SettingsView()
        .environmentObject(ClipboardManager())
}
