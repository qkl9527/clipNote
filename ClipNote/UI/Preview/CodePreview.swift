import SwiftUI

/// 代码预览组件
struct CodePreview: View {
    let code: String
    let language: String?
    
    @State private var highlightedCode: AttributedString?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundColor(.green)
                Text(language ?? "代码")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                Button(action: copyCode) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("复制")
                    }
                    .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            ScrollView([.horizontal, .vertical]) {
                if let highlighted = highlightedCode {
                    Text(highlighted)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                } else {
                    Text(code)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
        }
        .padding()
        .onAppear {
            highlightCode()
        }
        .onChange(of: code) { _, _ in
            highlightCode()
        }
    }
    
    private func highlightCode() {
        highlightedCode = CodeHighlighter.shared.highlight(code, language: language)
    }
    
    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
    }
}

#Preview {
    CodePreview(
        code: """
        func hello() {
            print("Hello, World!")
        }
        """,
        language: "Swift"
    )
    .frame(width: 400, height: 200)
}
