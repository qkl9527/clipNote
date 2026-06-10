import Foundation
import GRDB
import Combine

/// SQLite 存储管理器
class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    @Published var clips: [ClipItem] = []
    
    private var dbQueue: DatabaseQueue?
    private let maxItems: Int
    
    init(maxItems: Int = 1000) {
        self.maxItems = maxItems
        setupDatabase()
    }
    
    deinit {
        try? dbQueue?.close()
    }
    
    // MARK: - 数据库设置
    
    private func setupDatabase() {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("无法获取 Application Support 目录")
            return
        }
        
        let appDir = appSupport.appendingPathComponent("ClipNote")
        try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        
        let dbPath = appDir.appendingPathComponent("clipnote.db").path
        
        do {
            dbQueue = try DatabaseQueue(path: dbPath)
            try createTables()
            loadClips()
        } catch {
            print("数据库初始化失败: \(error)")
        }
    }
    
    private func createTables() throws {
        try dbQueue?.write { db in
            // 创建 clips 表
            try db.create(table: "clips", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("content", .text).notNull()
                t.column("category", .text).notNull()
                t.column("sourceApp", .text)
                t.column("sourceBundleId", .text)
                t.column("timestamp", .datetime).notNull()
                t.column("isPinned", .boolean).defaults(to: false)
                t.column("isFavorite", .boolean).defaults(to: false)
                t.column("rawRTF", .blob)
                t.column("rawHTML", .blob)
                t.column("imageData", .blob)
                t.column("fileURL", .text)
                t.column("codeLanguage", .text)
                t.column("charCount", .integer)
                t.column("byteSize", .integer)
            }
            
            // 创建 FTS5 全文索引
            try db.execute(sql: """
                CREATE VIRTUAL TABLE IF NOT EXISTS clips_fts USING fts5(
                    content,
                    sourceApp,
                    category,
                    content='clips',
                    content_rowid='rowid'
                )
            """)
        }
    }
    
    // MARK: - CRUD 操作
    
    /// 保存剪贴板条目
    func save(_ item: ClipItem) {
        // 检查是否已存在相同内容
        if let existingItem = findDuplicate(item) {
            // 更新时间戳
            updateTimestamp(for: existingItem.id)
            return
        }
        
        do {
            try dbQueue?.write { db in
                try item.insert(db)
                
                // 更新 FTS 索引
                try db.execute(sql: """
                    INSERT INTO clips_fts(rowid, content, sourceApp, category)
                    SELECT rowid, content, sourceApp, category FROM clips WHERE id = ?
                """, arguments: [item.id.uuidString])
            }
            
            // 限制总条目数
            trimToMaxItems()
            
            // 更新内存中的列表
            loadClips()
        } catch {
            print("保存失败: \(error)")
        }
    }
    
    /// 查找重复条目
    private func findDuplicate(_ item: ClipItem) -> ClipItem? {
        return try? dbQueue?.read { db in
            try ClipItem
                .filter(Column("content") == item.content)
                .fetchOne(db)
        }
    }
    
    /// 更新时间戳
    private func updateTimestamp(for id: UUID) {
        try? dbQueue?.write { db in
            try db.execute(sql: """
                UPDATE clips SET timestamp = ? WHERE id = ?
            """, arguments: [Date(), id.uuidString])
        }
    }
    
    /// 加载所有剪贴板条目
    func loadClips() {
        do {
            let items = try dbQueue?.read { db in
                try ClipItem
                    .order(Column("timestamp").desc)
                    .limit(maxItems)
                    .fetchAll(db)
            }
            
            DispatchQueue.main.async {
                self.clips = items ?? []
            }
        } catch {
            print("加载失败: \(error)")
        }
    }
    
    /// 获取最近的条目
    func fetchRecent(limit: Int = 5) -> [ClipItem] {
        return (try? dbQueue?.read { db in
            try ClipItem
                .order(Column("timestamp").desc)
                .limit(limit)
                .fetchAll(db)
        }) ?? []
    }
    
    /// 按分类筛选
    func fetchByCategory(_ category: ClipCategory) -> [ClipItem] {
        return (try? dbQueue?.read { db in
            try ClipItem
                .filter(Column("category") == category.rawValue)
                .order(Column("timestamp").desc)
                .fetchAll(db)
        }) ?? []
    }
    
    /// 搜索内容
    func search(query: String) -> [ClipItem] {
        guard !query.isEmpty else { return clips }
        
        return (try? dbQueue?.read { db in
            try ClipItem
                .filter(Column("content").like("%\(query)%"))
                .order(Column("timestamp").desc)
                .fetchAll(db)
        }) ?? []
    }
    
    /// 切换固定状态
    func togglePin(for id: UUID) {
        try? dbQueue?.write { db in
            try db.execute(sql: """
                UPDATE clips SET isPinned = NOT isPinned WHERE id = ?
            """, arguments: [id.uuidString])
        }
        loadClips()
    }
    
    /// 切换收藏状态
    func toggleFavorite(for id: UUID) {
        try? dbQueue?.write { db in
            try db.execute(sql: """
                UPDATE clips SET isFavorite = NOT isFavorite WHERE id = ?
            """, arguments: [id.uuidString])
        }
        loadClips()
    }
    
    /// 删除条目
    func delete(_ id: UUID) {
        try? dbQueue?.write { db in
            try db.execute(sql: "DELETE FROM clips WHERE id = ?", arguments: [id.uuidString])
            try db.execute(sql: """
                DELETE FROM clips_fts WHERE rowid = (SELECT rowid FROM clips WHERE id = ?)
            """, arguments: [id.uuidString])
        }
        loadClips()
    }
    
    /// 清空所有条目
    func clearAll() {
        try? dbQueue?.write { db in
            try db.execute(sql: "DELETE FROM clips")
            try db.execute(sql: "DELETE FROM clips_fts")
        }
        loadClips()
    }
    
    // MARK: - 辅助方法
    
    /// 限制条目数量
    private func trimToMaxItems() {
        try? dbQueue?.write { db in
            let count = try ClipItem.fetchCount(db)
            if count > maxItems {
                let excess = count - maxItems
                try db.execute(sql: """
                    DELETE FROM clips WHERE id IN (
                        SELECT id FROM clips ORDER BY timestamp ASC LIMIT ?
                    )
                """, arguments: [excess])
            }
        }
    }
    
    /// 获取总条目数
    var totalCount: Int {
        return (try? dbQueue?.read { db in
            try ClipItem.fetchCount(db)
        }) ?? 0
    }
    
    /// 获取分类统计
    func categoryCounts() -> [ClipCategory: Int] {
        var counts: [ClipCategory: Int] = [:]
        
        for category in ClipCategory.allCases {
            counts[category] = (try? dbQueue?.read { db in
                try ClipItem
                    .filter(Column("category") == category.rawValue)
                    .fetchCount(db)
            }) ?? 0
        }
        
        return counts
    }
}
