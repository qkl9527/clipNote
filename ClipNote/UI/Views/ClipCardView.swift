import SwiftUI

/// 单张卡片视图
struct ClipCardView: View {
    let item: ClipItem
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // 卡片头部：分类图标 + 标签
                HStack {
                    Image(systemName: item.category.icon)
                        .font(.caption)
                        .foregroundColor(categoryColor)
                    
                    Text(item.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
                
                // 内容预览
                contentPreview
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // 底部信息
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                    
                    HStack {
                        Text(item.formattedTime)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let sourceApp = item.sourceApp {
                            Text(sourceApp)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(12)
            .background(cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: isHovering ? 8 : 4, y: isHovering ? 4 : 2)
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    @ViewBuilder
    private var contentPreview: some View {
        switch item.category {
        case .text, .link, .code, .markdown:
            Text(item.previewText(maxLines: 5))
                .font(.caption)
                .lineLimit(5)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        case .html:
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText(maxLines: 3))
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundColor(.primary)
                
                Text("HTML")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
            }
            
        case .richText:
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText(maxLines: 3))
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundColor(.primary)
                
                Text("RTF")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(4)
            }
            
        case .image, .imageBase64:
            if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 180)
                    .cornerRadius(6)
            } else {
                imagePlaceholder
            }
            
        case .imageUrl:
            VStack(alignment: .leading, spacing: 4) {
                Text(item.content)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.blue)
                
                imagePlaceholder
            }
            
        case .file:
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(item.content)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private var imagePlaceholder: some View {
        VStack {
            Spacer()
            Image(systemName: "photo")
                .font(.title)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
    
    private var cardBackground: some View {
        Group {
            if isSelected {
                Color.accentColor.opacity(0.1)
            } else if isHovering {
                Color(nsColor: .controlBackgroundColor)
            } else {
                Color(nsColor: .windowBackgroundColor)
            }
        }
    }
    
    private var categoryColor: Color {
        switch item.category {
        case .text: return .blue
        case .link: return .purple
        case .code: return .green
        case .markdown: return .orange
        case .html: return .red
        case .richText: return .pink
        case .imageUrl: return .cyan
        case .imageBase64: return .teal
        case .image: return .indigo
        case .file: return .gray
        }
    }
}

#Preview {
    ClipCardView(
        item: ClipItem(
            content: "这是一段测试文本内容，用于预览卡片效果。",
            category: .text,
            sourceApp: "Safari"
        ),
        isSelected: false,
        onTap: {}
    )
    .frame(width: 200, height: 280)
}
