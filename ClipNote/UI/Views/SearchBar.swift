import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(ClipNoteTheme.muted)
            
            TextField("搜索剪贴板内容...", text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .font(.system(size: 13))
                .foregroundColor(ClipNoteTheme.ink)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(ClipNoteTheme.mutedSoft)
                }
                .buttonStyle(.plain)
            }
            
            KeyboardShortcutBadge(keys: "⌘K")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(ClipNoteTheme.surfaceSoft)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? ClipNoteTheme.primary.opacity(0.55) : ClipNoteTheme.hairline, lineWidth: 1)
        )
        .onAppear {
            isFocused = true
        }
    }
}

struct KeyboardShortcutBadge: View {
    let keys: String
    
    var body: some View {
        Text(keys)
            .font(.caption2)
            .foregroundColor(ClipNoteTheme.muted)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(ClipNoteTheme.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(ClipNoteTheme.hairline, lineWidth: 1)
            )
    }
}

#Preview {
    SearchBar(text: .constant("搜索"))
        .frame(width: 400)
}
