import SwiftUI

/// 水平滚动卡片列表
struct HorizontalCardList: View {
    let clips: [ClipItem]
    let onPaste: (ClipItem) -> Void
    
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            if clips.isEmpty {
                emptyStateView
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
                        ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                            ClipCardView(
                                item: clip,
                                isSelected: selectedIndex == index,
                                onTap: {
                                    selectedIndex = index
                                    onPaste(clip)
                                }
                            )
                            .frame(width: 200, height: 280)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("暂无剪贴板记录")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("复制内容后会自动显示在这里")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HorizontalCardList(clips: [], onPaste: { _ in })
        .frame(width: 900, height: 400)
}
