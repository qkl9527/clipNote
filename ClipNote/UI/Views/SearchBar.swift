import SwiftUI

/// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索剪贴板内容...", text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            KeyboardShortcutBadge(keys: "⌘K")
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .onAppear {
            isFocused = true
        }
    }
}

/// 键盘快捷键徽章
struct KeyboardShortcutBadge: View {
    let keys: String
    
    var body: some View {
        Text(keys)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(nsColor: .separatorColor))
            .cornerRadius(4)
    }
}

#Preview {
    SearchBar(text: .constant("搜索"))
        .frame(width: 400)
}
