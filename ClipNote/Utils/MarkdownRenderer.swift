import Foundation
import WebKit

/// Markdown 渲染工具
class MarkdownRenderer {
    static let shared = MarkdownRenderer()
    
    private init() {}
    
    /// 将 Markdown 转换为 HTML
    func renderToHTML(_ markdown: String) -> String {
        var html = markdown
        
        // 标题
        html = html.replacingOccurrences(of: "^# (.+)$", with: "<h1>$1</h1>", options: .regularExpression)
        html = html.replacingOccurrences(of: "^## (.+)$", with: "<h2>$1</h2>", options: .regularExpression)
        html = html.replacingOccurrences(of: "^### (.+)$", with: "<h3>$1</h3>", options: .regularExpression)
        html = html.replacingOccurrences(of: "^#### (.+)$", with: "<h4>$1</h4>", options: .regularExpression)
        html = html.replacingOccurrences(of: "^##### (.+)$", with: "<h5>$1</h5>", options: .regularExpression)
        html = html.replacingOccurrences(of: "^###### (.+)$", with: "<h6>$1</h6>", options: .regularExpression)
        
        // 粗体和斜体
        html = html.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "<strong>$1</strong>", options: .regularExpression)
        html = html.replacingOccurrences(of: "\\*(.+?)\\*", with: "<em>$1</em>", options: .regularExpression)
        
        // 代码块
        html = html.replacingOccurrences(of: "```(\\w*)\\n([\\s\\S]*?)```", with: "<pre><code class=\"$1\">$2</code></pre>", options: .regularExpression)
        
        // 行内代码
        html = html.replacingOccurrences(of: "`([^`]+)`", with: "<code>$1</code>", options: .regularExpression)
        
        // 链接
        html = html.replacingOccurrences(of: "\\[(.+?)\\]\\((.+?)\\)", with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        
        // 图片
        html = html.replacingOccurrences(of: "!(.+?)\\[(.+?)\\]\\((.+?)\\)", with: "<img src=\"$3\" alt=\"$2\">", options: .regularExpression)
        
        // 引用
        html = html.replacingOccurrences(of: "^> (.+)$", with: "<blockquote>$1</blockquote>", options: .regularExpression)
        
        // 无序列表
        html = html.replacingOccurrences(of: "^- (.+)$", with: "<li>$1</li>", options: .regularExpression)
        
        // 有序列表
        html = html.replacingOccurrences(of: "^\\d+\\. (.+)$", with: "<li>$1</li>", options: .regularExpression)
        
        // 分隔线
        html = html.replacingOccurrences(of: "^---$", with: "<hr>", options: .regularExpression)
        
        // 换行
        html = html.replacingOccurrences(of: "\n", with: "<br>")
        
        // 包装在 HTML 结构中
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                }
                pre {
                    background-color: #f5f5f5;
                    padding: 12px;
                    border-radius: 6px;
                    overflow-x: auto;
                }
                code {
                    font-family: "SF Mono", Monaco, Menlo, monospace;
                    font-size: 14px;
                }
                blockquote {
                    border-left: 4px solid #ddd;
                    margin: 0;
                    padding-left: 16px;
                    color: #666;
                }
                a {
                    color: #0066cc;
                    text-decoration: none;
                }
                a:hover {
                    text-decoration: underline;
                }
                img {
                    max-width: 100%;
                    height: auto;
                }
            </style>
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
    }
    
    /// 将 Markdown 渲染为 AttributedString
    func renderToAttributedString(_ markdown: String) -> AttributedString {
        let attributedString = AttributedString(markdown)
        return attributedString
    }
    
    /// 获取纯文本版本
    func plainText(_ markdown: String) -> String {
        var text = markdown
        
        // 移除 Markdown 语法
        text = text.replacingOccurrences(of: "^#{1,6}\\s+", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\*(.+?)\\*", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "```[\\s\\S]*?```", with: "[代码块]", options: .regularExpression)
        text = text.replacingOccurrences(of: "`([^`]+)`", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\[(.+?)\\]\\((.+?)\\)", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "^> ", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "^- ", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "^\\d+\\. ", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "^---$", with: "", options: .regularExpression)
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
