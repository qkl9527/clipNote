import SwiftUI

/// 文本预览组件
struct TextPreview: View {
    let content: String
    let maxLines: Int
    
    init(content: String, maxLines: Int = 10) {
        self.content = content
        self.maxLines = maxLines
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                Text("纯文本")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(content.count) 字符")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                Text(content)
                    .font(.body)
                    .lineLimit(maxLines)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview {
    TextPreview(content: "这是一段测试文本内容。\n第二行文本。\n第三行文本。")
        .frame(width: 400, height: 200)
}
