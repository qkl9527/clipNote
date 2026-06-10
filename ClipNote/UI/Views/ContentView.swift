import SwiftUI

/// 主视图 - 浮动面板内容
struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var searchText = ""
    @State private var selectedCategory: ClipCategory? = nil
    
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
        }
    }
    
    private var filteredClips: [ClipItem] {
        clipboardManager.filteredClips
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardManager())
}
