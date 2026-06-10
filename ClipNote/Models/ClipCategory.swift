import Foundation
import GRDB

/// 剪贴板条目分类
enum ClipCategory: String, Codable, CaseIterable, DatabaseValueConvertible {
    case text = "text"
    case link = "link"
    case code = "code"
    case markdown = "markdown"
    case image = "image"
    case file = "file"
    case html = "html"
    case richText = "richText"
    case imageUrl = "imageUrl"
    case imageBase64 = "imageBase64"
    
    var displayName: String {
        switch self {
        case .text: return "纯文本"
        case .link: return "链接"
        case .code: return "代码"
        case .markdown: return "Markdown"
        case .image: return "图片"
        case .file: return "文件"
        case .html: return "HTML"
        case .richText: return "富文本"
        case .imageUrl: return "图片链接"
        case .imageBase64: return "Base64图片"
        }
    }
    
    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .link: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .markdown: return "doc.richtext"
        case .html: return "globe"
        case .richText: return "doc.richtext"
        case .imageUrl: return "photo"
        case .imageBase64: return "photo.stack"
        case .image: return "photo"
        case .file: return "doc"
        }
    }
    
    var color: String {
        switch self {
        case .text: return "blue"
        case .link: return "purple"
        case .code: return "green"
        case .markdown: return "orange"
        case .html: return "red"
        case .richText: return "pink"
        case .imageUrl: return "cyan"
        case .imageBase64: return "teal"
        case .image: return "indigo"
        case .file: return "gray"
        }
    }
}
