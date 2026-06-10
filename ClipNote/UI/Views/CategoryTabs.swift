import SwiftUI

/// 分类标签组件
struct CategoryTabs: View {
    @Binding var selectedCategory: ClipCategory?
    
    private let categories: [ClipCategory?] = [nil] + ClipCategory.allCases
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                    CategoryTab(
                        title: category?.displayName ?? "全部",
                        icon: category?.icon ?? "tray.full",
                        shortcut: shortcutLabel(for: index),
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
        }
    }

    private func shortcutLabel(for index: Int) -> String? {
        ""
//        index <= 9 ? "⌘⌥\(index)" : nil
    }
}

/// 单个分类标签
struct CategoryTab: View {
    let title: String
    let icon: String
    let shortcut: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .medium : .regular)

                if let shortcut {
                    Text(shortcut)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryTabs(selectedCategory: .constant(nil))
}
