import SwiftUI
import AppKit

/// 主视图 - 浮动面板内容
struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var searchText = ""
    @State private var selectedCategory: ClipCategory? = nil
    @State private var keyDownMonitor: Any?

    private let categoryShortcuts: [ClipCategory?] = [nil] + Array(ClipCategory.allCases.prefix(9))
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            SearchBar(text: $searchText)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // 分类标签
            CategoryTabs(selectedCategory: $selectedCategory)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            Divider()
            
            // 水平滚动卡片列表
            HorizontalCardList(
                clips: filteredClips,
                onPaste: { item in
                    clipboardManager.paste(item)
                    PanelManager.shared.hidePanel()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            // 底部状态栏
            HStack {
                Text("共 \(clipboardManager.clips.count) 条记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("⌥⌘V 唤出")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    NotificationCenter.default.post(name: .clipNoteOpenSettings, object: nil)
                }) {
                    Image(systemName: "gear")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(minWidth: 640, minHeight: 320)
        .background(Color(nsColor: .windowBackgroundColor))
        .onChange(of: searchText) { _, newValue in
            clipboardManager.searchText = newValue
        }
        .onChange(of: selectedCategory) { _, newValue in
            clipboardManager.selectCategory(newValue)
        }
        .onAppear {
            clipboardManager.startMonitoring()
            installKeyDownMonitor()
        }
        .onDisappear {
            removeKeyDownMonitor()
        }
    }
    
    private var filteredClips: [ClipItem] {
        clipboardManager.filteredClips
    }

    private func installKeyDownMonitor() {
        guard keyDownMonitor == nil else { return }

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if handleKeyDown(event) {
                return nil
            }
            return event
        }
    }

    private func removeKeyDownMonitor() {
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
        }
        keyDownMonitor = nil
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let characters = event.charactersIgnoringModifiers?.lowercased()

        if flags.contains(.command), characters == "k" {
            searchText = ""
            clipboardManager.clearSearch()
            return true
        }

        if flags.contains(.command), flags.contains(.option), let characters, let index = Int(characters) {
            guard categoryShortcuts.indices.contains(index) else { return false }
            selectedCategory = categoryShortcuts[index]
            clipboardManager.selectCategory(categoryShortcuts[index])
            return true
        }

        return false
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardManager())
}
