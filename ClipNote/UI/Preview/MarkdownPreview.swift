import SwiftUI
import WebKit

/// Markdown 预览组件
struct MarkdownPreview: View {
    let content: String
    @State private var showPreview = false
    @State private var htmlContent: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.richtext")
                    .foregroundColor(.orange)
                Text("Markdown")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                Picker("", selection: $showPreview) {
                    Text("源码").tag(false)
                    Text("预览").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            
            if showPreview {
                HTMLWebView(html: htmlContent)
                    .background(Color.white)
                    .cornerRadius(6)
            } else {
                ScrollView {
                    Text(content)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
            }
        }
        .padding()
        .onAppear {
            htmlContent = MarkdownRenderer.shared.renderToHTML(content)
        }
        .onChange(of: content) { _, _ in
            htmlContent = MarkdownRenderer.shared.renderToHTML(content)
        }
    }
}

/// HTML WebView 组件
struct HTMLWebView: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    MarkdownPreview(content: """
    # 标题
    
    **加粗文本** 和 *斜体文本*
    
    - 列表项 1
    - 列表项 2
    
    ```swift
    let x = 42
    ```
    """)
    .frame(width: 400, height: 300)
}
