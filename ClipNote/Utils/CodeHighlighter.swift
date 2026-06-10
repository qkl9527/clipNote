import Foundation
import Highlightr

/// 代码语法高亮工具
class CodeHighlighter {
    static let shared = CodeHighlighter()
    
    private let highlightr: Highlightr?
    
    private init() {
        highlightr = Highlightr()
        highlightr?.setTheme(to: "monokai")
    }
    
    /// 获取语法高亮后的代码
    func highlight(_ code: String, language: String? = nil) -> AttributedString? {
        guard let highlightr = highlightr else { return nil }
        
        let lang = language ?? detectLanguage(code)
        
        if let highlightedCode = highlightr.highlight(code, as: lang) {
            return try? AttributedString(highlightedCode, including: \.appKit)
        }
        
        return AttributedString(code)
    }
    
    /// 检测代码语言
    private func detectLanguage(_ code: String) -> String? {
        let languagePatterns: [(String, [String])] = [
            ("swift", ["func\\s+\\w+\\s*\\(", "var\\s+\\w+", "let\\s+\\w+", "import\\s+UIKit"]),
            ("javascript", ["const\\s+\\w+", "let\\s+\\w+", "function\\s+\\w+", "=>\\s*\\{"]),
            ("python", ["def\\s+\\w+", "import\\s+\\w+", "from\\s+\\w+\\s+import"]),
            ("html", ["<html", "<div", "<span", "<body"]),
            ("css", ["\\{\\s*[\\w-]+\\s*:", "@media", "@keyframes"]),
            ("sql", ["SELECT\\s+", "FROM\\s+", "WHERE\\s+"]),
            ("go", ["func\\s+\\w+\\s*\\(", "package\\s+\\w+"]),
            ("rust", ["fn\\s+\\w+", "let\\s+mut\\s+", "impl\\s+"]),
            ("java", ["public\\s+class", "private\\s+\\w+"]),
            ("c", ["#include\\s+<", "int\\s+main\\s*\\("])
        ]
        
        for (language, patterns) in languagePatterns {
            for pattern in patterns {
                if code.range(of: pattern, options: .regularExpression) != nil {
                    return language
                }
            }
        }
        
        return nil
    }
    
    /// 获取可用主题列表
    func availableThemes() -> [String] {
        return highlightr?.availableThemes() ?? []
    }
    
    /// 设置主题
    func setTheme(_ theme: String) {
        highlightr?.setTheme(to: theme)
    }
}
