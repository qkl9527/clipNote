import SwiftUI

struct CategoryTabs: View {
    @Binding var selectedCategory: ClipCategory?
    @AppStorage("showCategoryShortcuts") private var showCategoryShortcuts: Bool = true
    
    private let categories: [ClipCategory?] = [nil] + ClipCategory.allCases
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
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
        guard showCategoryShortcuts else { return nil }
        return index <= 9 ? "⌘⌥\(index)" : nil
    }
}

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
                    .font(.system(size: 11, weight: .medium))
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .fontWeight(isSelected ? .medium : .regular)

                if let shortcut {
                    Text(shortcut)
                        .font(.caption2)
                        .foregroundColor(isSelected ? Color.white.opacity(0.78) : ClipNoteTheme.mutedSoft)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(isSelected ? ClipNoteTheme.primary : ClipNoteTheme.surfaceSoft.opacity(0.72))
            .foregroundColor(isSelected ? .white : ClipNoteTheme.body)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isSelected ? ClipNoteTheme.primaryActive.opacity(0.2) : ClipNoteTheme.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryTabs(selectedCategory: .constant(nil))
}
