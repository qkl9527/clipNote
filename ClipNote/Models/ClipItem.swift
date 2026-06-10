import Foundation
import GRDB

/// 剪贴板条目模型
struct ClipItem: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "clips"
    
    let id: UUID
    var content: String
    var category: ClipCategory
    var sourceApp: String?
    var sourceBundleId: String?
    var timestamp: Date
    var isPinned: Bool
    var isFavorite: Bool
    var rawRTF: Data?
    var rawHTML: Data?
    var imageData: Data?
    var fileURL: String?
    var codeLanguage: String?
    var charCount: Int
    var byteSize: Int
    
    init(
        id: UUID = UUID(),
        content: String,
        category: ClipCategory,
        sourceApp: String? = nil,
        sourceBundleId: String? = nil,
        timestamp: Date = Date(),
        isPinned: Bool = false,
        isFavorite: Bool = false,
        rawRTF: Data? = nil,
        rawHTML: Data? = nil,
        imageData: Data? = nil,
        fileURL: String? = nil,
        codeLanguage: String? = nil
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.sourceApp = sourceApp
        self.sourceBundleId = sourceBundleId
        self.timestamp = timestamp
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.rawRTF = rawRTF
        self.rawHTML = rawHTML
        self.imageData = imageData
        self.fileURL = fileURL
        self.codeLanguage = codeLanguage
        self.charCount = content.count
        self.byteSize = content.utf8.count
    }
    
    /// 获取预览文本（限制行数）
    func previewText(maxLines: Int = 4) -> String {
        let lines = content.components(separatedBy: .newlines)
        if lines.count <= maxLines {
            return content
        }
        return lines.prefix(maxLines).joined(separator: "\n") + "..."
    }
    
    /// 格式化时间
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
    
    /// 格式化日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: timestamp)
    }
    
    /// 格式化文件大小
    var formattedSize: String {
        if byteSize < 1024 {
            return "\(byteSize) B"
        } else if byteSize < 1024 * 1024 {
            return String(format: "%.1f KB", Double(byteSize) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(byteSize) / (1024.0 * 1024.0))
        }
    }
}
