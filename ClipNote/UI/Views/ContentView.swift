import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var searchText = ""
    @State private var selectedCategory: ClipCategory? = nil
    @State private var keyDownMonitor: Any?

    private let categoryShortcuts: [ClipCategory?] = [nil] + Array(ClipCategory.allCases.prefix(9))
    
    var body: some View {
        VStack(spacing: 0) {
            header

            Rectangle()
                .fill(ClipNoteTheme.hairline)
                .frame(height: 1)

            HorizontalCardList(
                clips: filteredClips,
                onPaste: { item in
                    clipboardManager.paste(item)
                    PanelManager.shared.hidePanel()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Rectangle()
                .fill(ClipNoteTheme.hairlineSoft)
                .frame(height: 1)

            footer
        }
        .frame(minWidth: 300, minHeight: 260)
        .background(ClipNoteTheme.canvas)
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

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    ClipNoteLogoView(size: 20)

                    Text("ClipNote")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ClipNoteTheme.ink)
                }
                .frame(width: 96, alignment: .leading)

                SearchBar(text: $searchText)

                Button(action: {
                    NotificationCenter.default.post(name: .clipNoteOpenSettings, object: nil)
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 26, height: 26)
                        .foregroundColor(ClipNoteTheme.body)
                        .background(ClipNoteTheme.surfaceSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(ClipNoteTheme.hairline, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            CategoryTabs(selectedCategory: $selectedCategory)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Label("共 \(clipboardManager.clips.count) 条记录", systemImage: "tray.full")
                .font(.caption)
                .foregroundColor(ClipNoteTheme.muted)

            if let selectedCategory {
                Text(selectedCategory.displayName)
                    .font(.caption)
                    .foregroundColor(ClipNoteTheme.primaryActive)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(ClipNoteTheme.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Spacer()

            Text("⌥⌘V 唤出")
                .font(.caption)
                .foregroundColor(ClipNoteTheme.muted)

            Text("拖拽 或 点击卡片粘贴")
                .font(.caption)
                .foregroundColor(ClipNoteTheme.mutedSoft)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(ClipNoteTheme.surfaceSoft.opacity(0.75))
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
