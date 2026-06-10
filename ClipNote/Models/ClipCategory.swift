import Foundation
import GRDB

/// 剪贴板条目分类
enum ClipCategory: String, Codable, CaseIterable, DatabaseValueConvertible {
    case text = "text"
    case link = "link"
    case code = "code"
    case image = "image"
    case file = "file"
    case html = "html"
    case richText = "richText"

    var displayName: String {
        switch self {
        case .text: return "纯文本"
        case .link: return "链接"
        case .code: return "代码"
        case .image: return "图片"
        case .file: return "文件"
        case .html: return "HTML"
        case .richText: return "富文本"
        }
    }

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .link: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .image: return "photo"
        case .file: return "doc"
        case .html: return "globe"
        case .richText: return "doc.richtext"
        }
    }

    var color: String {
        switch self {
        case .text: return "blue"
        case .link: return "purple"
        case .code: return "green"
        case .html: return "red"
        case .richText: return "pink"
        case .image: return "indigo"
        case .file: return "gray"
        }
    }
}
