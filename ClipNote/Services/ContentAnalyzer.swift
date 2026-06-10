import Foundation
import AppKit

/// 内容智能分类器
class ContentAnalyzer {
    static let shared = ContentAnalyzer()
    private let maxTextAnalysisLength = 200_000
    private let maxStoredTextLength = 500_000
    private let maxBase64DecodeLength = 8_000_000

    private init() {}

    /// 分析剪贴板内容并分类
    func analyze(item: NSPasteboardItem, sourceApp: String?, sourceBundleId: String? = nil) -> ClipItem? {
        // Step 1: 检查二进制数据（图片）
        if let imageData = analyzeImage(item: item, sourceApp: sourceApp, sourceBundleId: sourceBundleId) {
            return imageData
        }

        // Step 2: 检查文件URL
        if let fileItem = analyzeFile(item: item, sourceApp: sourceApp, sourceBundleId: sourceBundleId) {
            return fileItem
        }

        // Step 3: 检查富文本格式
        if let richTextItem = analyzeRichText(item: item, sourceApp: sourceApp, sourceBundleId: sourceBundleId) {
            return richTextItem
        }

        // Step 4: 检查纯文本内容
        if let text = item.string(forType: .string) {
            return analyzeText(text, item: item, sourceApp: sourceApp, sourceBundleId: sourceBundleId)
        }

        return nil
    }

    // MARK: - 图片分析

    private func analyzeImage(item: NSPasteboardItem, sourceApp: String?, sourceBundleId: String?) -> ClipItem? {
        // 检查 TIFF/PNG 图片数据
        if let tiffData = item.data(forType: .tiff),
           let image = NSImage(data: tiffData) {
            let category: ClipCategory = detectImageFormat(data: tiffData) == "PNG" ? .image : .image
            return ClipItem(
                content: "[图片 \(Int(image.size.width))×\(Int(image.size.height))]",
                category: category,
                sourceApp: sourceApp,
                sourceBundleId: sourceBundleId,
                imageData: tiffData
            )
        }

        if let pngData = item.data(forType: .png) {
            return ClipItem(
                content: "[PNG 图片]",
                category: .image,
                sourceApp: sourceApp,
                sourceBundleId: sourceBundleId,
                imageData: pngData
            )
        }

        return nil
    }

    /// 检测图片格式
    private func detectImageFormat(data: Data) -> String {
        let bytes = [UInt8](data.prefix(4))
        if bytes.count >= 4 {
            if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
                return "PNG"
            } else if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
                return "JPEG"
            } else if bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 {
                return "GIF"
            }
        }
        return "TIFF"
    }

    // MARK: - 文件分析

    private func analyzeFile(item: NSPasteboardItem, sourceApp: String?, sourceBundleId: String?) -> ClipItem? {
        guard let fileData = item.data(forType: .fileURL),
          let urlString = String(data: fileData, encoding: .utf8),
          let url = URL(string: urlString) else {
            return nil
        }

        let fileName = url.lastPathComponent
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0

        return ClipItem(
            content: "\(fileName) (\(formatFileSize(fileSize)))",
            category: .file,
            sourceApp: sourceApp,
            sourceBundleId: sourceBundleId,
            fileURL: url.path
        )
    }

    // MARK: - 富文本分析

    private func analyzeRichText(item: NSPasteboardItem, sourceApp: String?, sourceBundleId: String?) -> ClipItem? {
        // 检查 RTF
        if let rtfData = item.data(forType: .rtf) {
            let plainText = rtfData.count > maxStoredTextLength ? "[富文本 \(formatFileSize(rtfData.count))]" : (extractPlainTextFromRTF(rtfData) ?? "[富文本]")
            return ClipItem(
                content: plainText,
                category: .richText,
                sourceApp: sourceApp,
                sourceBundleId: sourceBundleId,
                rawRTF: rtfData
            )
        }

        // 检查 HTML
        if let htmlData = item.data(forType: .html) {
            let htmlString = String(data: htmlData, encoding: .utf8) ?? ""
            let plainText = htmlString.count > maxTextAnalysisLength ? truncate(htmlString, limit: maxStoredTextLength) : (extractPlainTextFromHTML(htmlString) ?? htmlString)
            return ClipItem(
                content: plainText,
                category: .html,
                sourceApp: sourceApp,
                sourceBundleId: sourceBundleId,
                rawHTML: htmlData
            )
        }

        return nil
    }

    /// 从 RTF 提取纯文本
    private func extractPlainTextFromRTF(_ data: Data) -> String? {
        guard let attrString = NSAttributedString(rtf: data, documentAttributes: nil) else {
            return nil
        }
        return attrString.string
    }

    /// 从 HTML 提取纯文本
    private func extractPlainTextFromHTML(_ html: String) -> String? {
        // 简单的 HTML 标签移除
        let pattern = "<[^>]+>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)) != nil else {
            return html
        }

        let cleaned = html.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 文本分析

    private func analyzeText(_ text: String, item: NSPasteboardItem, sourceApp: String?, sourceBundleId: String?) -> ClipItem? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let base64Item = checkBase64Image(trimmed, sourceApp: sourceApp, sourceBundleId: sourceBundleId) {
            return base64Item
        }

        let shouldAnalyze = trimmed.count <= maxTextAnalysisLength
        let category = shouldAnalyze ? detectTextCategory(trimmed) : .text

        // 检测代码语言
        let codeLanguage: String? = category == .code ? detectCodeLanguage(trimmed) : nil

        return ClipItem(
            content: truncate(trimmed, limit: maxStoredTextLength),
            category: category,
            sourceApp: sourceApp,
            sourceBundleId: sourceBundleId,
            codeLanguage: codeLanguage
        )
    }

    /// 检测文本分类
    private func detectTextCategory(_ text: String) -> ClipCategory {
        // 检查链接
        if isURL(text) {
            return .link
        }

        // 检查代码块
        if isCodeBlock(text) {
            return .code
        }

        // 默认为纯文本
        return .text
    }

    /// 判断是否为 URL
    private func isURL(_ text: String) -> Bool {
        let urlPattern = "^(https?|ftp)://[^\\s/$.?#].[^\\s]*$"
        let imageUrlPattern = "^(https?|ftp)://[^\\s]+$\\.(png|jpg|jpeg|gif|svg|webp|bmp|ico)(\\?.*)?$"

        let lowercased = text.lowercased()

        // 检查图片 URL
        if lowercased.range(of: imageUrlPattern, options: .regularExpression) != nil {
            return true
        }

        // 检查普通 URL
        return lowercased.range(of: urlPattern, options: .regularExpression) != nil
    }

    /// 判断是否为代码块
    private func isCodeBlock(_ text: String) -> Bool {
        let codePatterns = [
            "```[\\s\\S]*```",           // Markdown 代码块
            "func\\s+\\w+\\s*\\(",       // Swift/JS 函数
            "class\\s+\\w+",             // 类定义
            "import\\s+\\w+",            // 导入语句
            "def\\s+\\w+",               // Python 函数
            "SELECT\\s+.+\\s+FROM",      // SQL
            "<[a-z]+[>\\s]",             // HTML 标签
            "\\{[\\s]*\\\"",             // JSON
            "for\\s*\\(.*\\)",           // for 循环
            "if\\s*\\(.*\\)",            // if 语句
            "while\\s*\\(.*\\)",         // while 循环
            "//.*",                       // 单行注释
            "/\\*[\\s\\S]*\\*/",         // 多行注释
            "#include",                   // C/C++ 导入
            "package\\s+\\w+",           // Go/Java 包
            "enum\\s+\\w+",              // 枚举定义
            "struct\\s+\\w+"             // 结构体定义
        ]

        for pattern in codePatterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }

        // 检查缩进模式（多行代码）
        let lines = text.components(separatedBy: .newlines)
        if lines.count > 1 {
            let indentedLines = lines.filter { $0.hasPrefix("    ") || $0.hasPrefix("\t") }
            if Double(indentedLines.count) / Double(lines.count) > 0.5 {
                return true
            }
        }

        return false
    }

    /// 检测代码语言
    private func detectCodeLanguage(_ code: String) -> String? {
        let languagePatterns: [(String, [String])] = [
            ("Swift", ["func\\s+\\w+\\s*\\(", "var\\s+\\w+", "let\\s+\\w+", "import\\s+UIKit", "import\\s+SwiftUI"]),
            ("JavaScript", ["const\\s+\\w+", "let\\s+\\w+", "function\\s+\\w+", "=>\\s*\\{", "console\\.log"]),
            ("Python", ["def\\s+\\w+", "import\\s+\\w+", "from\\s+\\w+\\s+import", "class\\s+\\w+.*:"]),
            ("HTML", ["<html", "<div", "<span", "<body", "<head"]),
            ("CSS", ["\\{\\s*[\\w-]+\\s*:", "@media", "@keyframes", "\\.\\w+\\s*\\{"]),
            ("SQL", ["SELECT\\s+", "FROM\\s+", "WHERE\\s+", "INSERT\\s+INTO", "UPDATE\\s+\\w+\\s+SET"]),
            ("Go", ["func\\s+\\w+\\s*\\(", "package\\s+\\w+", "import\\s+\\("]),
            ("Rust", ["fn\\s+\\w+", "let\\s+mut\\s+", "impl\\s+", "pub\\s+fn"]),
            ("Java", ["public\\s+class", "private\\s+\\w+", "protected\\s+\\w+", "System\\.out\\.print"]),
            ("C/C++", ["#include\\s+<", "int\\s+main\\s*\\(", "printf\\s*\\(", "std::"])
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

    /// 检查是否为 Base64 图片
    private func checkBase64Image(_ text: String, sourceApp: String?, sourceBundleId: String?) -> ClipItem? {
        guard text.hasPrefix("data:image/"), let range = text.range(of: ";base64,") else {
            return nil
        }

        let header = String(text[..<range.lowerBound])
        let imageType = header.replacingOccurrences(of: "data:image/", with: "")
        guard !imageType.isEmpty else {
            return nil
        }

        let base64Slice = text[range.upperBound...]
        let estimatedSize = base64Slice.count * 3 / 4
        guard text.count <= maxBase64DecodeLength else {
            return ClipItem(
                content: "[Base64 \(imageType.uppercased()) 图片 \(formatFileSize(estimatedSize))，内容过大未解码]",
                category: .image,
                sourceApp: sourceApp,
                sourceBundleId: sourceBundleId
            )
        }

        let base64String = String(base64Slice)
        if let imageData = Data(base64Encoded: base64String) {
            return ClipItem(
                content: "[Base64 \(imageType.uppercased()) 图片]",
                category: .image,
                sourceApp: sourceApp,
                sourceBundleId: sourceBundleId,
                imageData: imageData
            )
        }

        return nil
    }

    /// 格式化文件大小
    private func formatFileSize(_ bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024.0 * 1024.0))
        }
    }

    private func truncate(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        return String(text.prefix(limit)) + "\n\n[内容过大，仅保存前 \(formatFileSize(limit))]"
    }
}
