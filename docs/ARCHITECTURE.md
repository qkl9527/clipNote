# ClipNote - 架构设计文档

## 1. 项目概述

ClipNote 是一款轻量级 macOS 原生剪贴板管理工具，支持快速唤出预览、一键粘贴到任意窗口。

### 1.1 核心特性

- ⚡ **轻量快速** - 原生 Swift 开发，启动迅速
- 🎯 **智能分类** - 自动识别10种内容类型
- 📋 **点击即粘贴** - 选中即可粘贴到焦点窗口
- 🔍 **全文搜索** - FTS5 索引，毫秒级搜索
- 🔒 **隐私优先** - 本地存储，跳过密码管理器内容

### 1.2 技术栈

| 组件 | 技术选择 | 版本要求 |
|------|----------|----------|
| 语言 | Swift 5.9+ | macOS 14+ |
| UI 框架 | SwiftUI + AppKit | - |
| 数据库 | SQLite (GRDB.swift) | 6.0+ |
| 全局快捷键 | KeyboardShortcuts | 2.4+ |
| 代码高亮 | Highlightr | latest |
| HTML 预览 | WKWebView | - |

## 2. 系统架构

### 2.1 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ContentView│ │CardView  │ │Preview   │ │Settings  │      │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘      │
│       │             │            │             │            │
├───────┴─────────────┴────────────┴─────────────┴────────────┤
│                      Business Layer                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                 ClipboardManager                     │  │
│  │  - 统一管理剪贴板操作                                 │  │
│  │  - 协调 Monitor 和 Storage                           │  │
│  └───────────────────────┬──────────────────────────────┘  │
│                          │                                  │
│  ┌──────────────┐ ┌──────┴──────┐ ┌──────────────┐        │
│  │ClipboardMonitor│ │PasteService │ │ContentAnalyzer│        │
│  │  (监听剪贴板)  │ │  (模拟粘贴)  │ │  (智能分类)   │        │
│  └──────┬───────┘ └─────────────┘ └──────┬───────┘        │
│         │                                 │                │
├─────────┴─────────────────────────────────┴────────────────┤
│                      Data Layer                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  StorageManager                      │  │
│  │  - SQLite + FTS5                                     │  │
│  │  - CRUD 操作                                         │  │
│  │  - 搜索和筛选                                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                      System Layer                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │NSPasteboard│ │CGEvent   │ │AXIsProcess│ │NSWorkspace│      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块职责

| 模块 | 文件 | 职责 |
|------|------|------|
| **App** | ClipNoteApp.swift | 应用入口，初始化 |
| | AppDelegate.swift | 菜单栏、全局快捷键 |
| **Models** | ClipItem.swift | 数据模型定义 |
| | ClipCategory.swift | 分类枚举 |
| **Services** | ClipboardMonitor.swift | 剪贴板监听 |
| | ClipboardManager.swift | 统一管理器 |
| | ContentAnalyzer.swift | 内容分析分类 |
| | StorageManager.swift | SQLite 持久化 |
| | PasteService.swift | 模拟粘贴 |
| **UI/Panel** | FloatingPanel.swift | NSPanel 浮动窗口 |
| | PanelManager.swift | 面板生命周期 |
| **UI/Views** | ContentView.swift | 主界面 |
| | HorizontalCardList.swift | 水平滚动列表 |
| | ClipCardView.swift | 卡片组件 |
| | SearchBar.swift | 搜索栏 |
| | CategoryTabs.swift | 分类标签 |
| **UI/Preview** | *Preview.swift | 各类型预览组件 |
| **Utils** | AccessibilityHelper.swift | 权限检测 |
| | CodeHighlighter.swift | 代码高亮 |
| | MarkdownRenderer.swift | Markdown 渲染 |

## 3. 数据流设计

### 3.1 剪贴板监听流程

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  NSPasteboard│     │ClipboardMonitor│    │ContentAnalyzer│
│  (系统剪贴板) │────▶│  (轮询监听)   │────▶│  (分析分类)   │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
                           │                    │
                           ▼                    ▼
                    ┌─────────────┐     ┌─────────────┐
                    │ StorageManager│    │ ClipboardManager│
                    │  (持久化)     │◀────│  (更新UI)     │
                    └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   Views     │
                                        │  (更新显示)  │
                                        └─────────────┘
```

### 3.2 粘贴流程

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  用户点击卡片 │────▶│ PasteService │────▶│NSPasteboard │
└─────────────┘     └──────┬──────┘     │  (写入剪贴板) │
                           │            └─────────────┘
                           ▼
                    ┌─────────────┐     ┌─────────────┐
                    │  隐藏面板    │────▶│  CGEvent    │
                    │ (0.05s延迟)  │     │ (模拟Cmd+V) │
                    └─────────────┘     └─────────────┘
```

## 4. 数据模型设计

### 4.1 ClipItem

```swift
struct ClipItem: Codable, FetchableRecord, PersistableRecord {
    let id: UUID                    // 唯一标识
    var content: String             // 主要文本内容
    var category: ClipCategory      // 分类
    var sourceApp: String?          // 来源应用
    var sourceBundleId: String?     // 来源 Bundle ID
    var timestamp: Date             // 复制时间
    var isPinned: Bool              // 是否固定
    var isFavorite: Bool            // 是否收藏
    var rawRTF: Data?               // 原始 RTF 数据
    var rawHTML: Data?              // 原始 HTML 数据
    var imageData: Data?            // 图片二进制数据
    var fileURL: String?            // 文件路径
    var codeLanguage: String?       // 代码语言
    var charCount: Int              // 字符数
    var byteSize: Int               // 字节数
}
```

### 4.2 ClipCategory

```swift
enum ClipCategory: String, Codable, CaseIterable {
    case text           // 纯文本
    case link           // 链接
    case code           // 代码块
    case markdown       // Markdown
    case html           // HTML
    case richText       // 富文本 (RTF)
    case imageUrl       // 图片 URL
    case imageBase64    // 图片 Base64
    case image          // 图片 (二进制)
    case file           // 文件
}
```

### 4.3 SQLite 表结构

```sql
-- 主表
CREATE TABLE clips (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    category TEXT NOT NULL,
    sourceApp TEXT,
    sourceBundleId TEXT,
    timestamp REAL NOT NULL,
    isPinned INTEGER DEFAULT 0,
    isFavorite INTEGER DEFAULT 0,
    rawRTF BLOB,
    rawHTML BLOB,
    imageData BLOB,
    fileURL TEXT,
    codeLanguage TEXT,
    charCount INTEGER,
    byteSize INTEGER
);

-- FTS5 全文索引
CREATE VIRTUAL TABLE clips_fts USING fts5(
    content,
    sourceApp,
    category,
    content='clips',
    content_rowid='rowid'
);
```

## 5. UI 设计

### 5.1 面板结构

```
┌─────────────────────────────────────────────────────────────┐
│  ⌥⌘V  ┌───────────────────────────────────────────────┐   │
│        │ 🔍 搜索...                              ⌘K   │   │
│        └───────────────────────────────────────────────┘   │
│        [全部] [文本] [链接] [代码] [图片] [富文本] [设置]    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ ◀ [卡片1] [卡片2] [卡片3] [卡片4] ... [卡片n] ▶    │  │
│  │                                                     │  │
│  │         水平滚动区域 (可拖动)                         │  │
│  └─────────────────────────────────────────────────────┘  │
│        共 N 条    ⌙ 设置    ⌘E 导出                       │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 卡片布局

```
┌────────────────────────┐
│ 📝 纯文本           📌 │  ← 分类 + 固定标记
│                        │
│ 这是一段复制的文本...   │  ← 内容预览 (4行)
│                        │
│ ────────────────────── │
│ 14:32  Safari          │  ← 时间 + 来源
└────────────────────────┘
```

## 6. 性能优化策略

| 策略 | 实现 |
|------|------|
| **轮询优化** | 0.5s 间隔，仅比较 changeCount |
| **图片懒加载** | 卡片显示时才加载图片 |
| **FTS5 索引** | 全文搜索毫秒级响应 |
| **内存限制** | 最多保存 1000 条记录 |
| **数据裁剪** | 超出限制自动删除旧记录 |

## 7. 安全设计

| 安全措施 | 实现 |
|----------|------|
| **密码跳过** | 检测 `org.nspasteboard.ConcealedType` |
| **密码管理器过滤** | 跳过 1Password、Bitwarden 等 |
| **本地存储** | 所有数据存储在本地 |
| **无网络** | 不发送任何网络请求 |

## 8. 扩展性设计

### 8.1 插件架构（预留）

```swift
protocol ClipProcessor {
    func process(_ item: ClipItem) -> ClipItem?
}
```

### 8.2 导出格式扩展

```swift
enum ExportFormat {
    case json
    case csv
    case markdown
    case plainText
}
```

## 9. 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| 数据库错误 | 日志记录，保持应用运行 |
| 权限错误 | 弹窗引导用户授权 |
| 图片加载失败 | 显示占位符 |
| 粘贴失败 | 降级为复制到剪贴板 |
