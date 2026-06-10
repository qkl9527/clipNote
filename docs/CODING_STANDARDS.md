# ClipNote - 技术规范文档

## 1. 编码规范

### 1.1 Swift 风格指南

遵循 [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide) 基本原则：

```swift
// ✅ 正确
class ClipboardManager {
    private var clips: [ClipItem] = []
    
    func fetchRecent(limit: Int) -> [ClipItem] {
        // ...
    }
}

// ❌ 错误
class clipboardManager {
    var clips:[ClipItem]=[];
    func fetchRecent(limit:Int)->[ClipItem]{
        // ...
    }
}
```

### 1.2 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类/结构体 | PascalCase | `ClipItem`, `StorageManager` |
| 函数/方法 | camelCase | `fetchRecent()`, `togglePin()` |
| 变量/常量 | camelCase | `changeCount`, `maxItems` |
| 枚举值 | camelCase | `.text`, `.link` |
| 协议 | PascalCase + Protocol | `ClipProcessorProtocol` |

### 1.3 注释规范

```swift
/// 剪贴板监听器
/// 负责监听系统剪贴板变化并通知上层
class ClipboardMonitor: ObservableObject {
    
    /// 开始监听剪贴板
    /// - Note: 使用 Timer 0.5s 轮询
    func startMonitoring() {
        // ...
    }
    
    /// 检查剪贴板内容是否为敏感信息
    /// - Parameter item: 剪贴板条目
    /// - Returns: 是否为敏感内容
    private func isSensitiveContent(item: NSPasteboardItem) -> Bool {
        // ...
    }
}
```

## 2. 错误处理规范

### 2.1 错误定义

```swift
enum ClipNoteError: Error {
    case databaseError(String)
    case accessibilityDenied
    case pasteFailed(String)
    case imageLoadFailed(String)
}

extension ClipNoteError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return "数据库错误: \(message)"
        case .accessibilityDenied:
            return "辅助功能权限未授权"
        case .pasteFailed(let message):
            return "粘贴失败: \(message)"
        case .imageLoadFailed(let message):
            return "图片加载失败: \(message)"
        }
    }
}
```

### 2.2 错误处理模式

```swift
// ✅ 正确 - 使用 do-catch
func loadClips() {
    do {
        let items = try dbQueue?.read { db in
            try ClipItem.fetchAll(db)
        }
        // ...
    } catch {
        print("加载失败: \(error)")
        // 记录日志，不崩溃
    }
}

// ✅ 正确 - 使用 try?
let count = (try? dbQueue?.read { db in
    try ClipItem.fetchCount(db)
}) ?? 0
```

## 3. 内存管理规范

### 3.1 循环引用避免

```swift
// ✅ 正确 - 使用 weak self
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.checkForChanges()
}

// ✅ 正确 - 使用 capture list
clipboardManager.$clips
    .sink { [weak self] clips in
        self?.clips = clips
    }
    .store(in: &cancellables)
```

### 3.2 大数据处理

```swift
// ✅ 正确 - 图片压缩
func compressImage(_ image: NSImage, maxWidth: CGFloat = 200) -> Data? {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData) else {
        return nil
    }
    
    let maxSize = NSSize(width: maxWidth, height: maxWidth)
    let scaledSize = image.size.scaledToFit(maxSize)
    
    bitmap.size = scaledSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current?.imageInterpolation = .high
    
    image.draw(in: NSRect(origin: .zero, size: scaledSize))
    
    NSGraphicsContext.restoreGraphicsState()
    
    return bitmap.representation(using: .png, properties: [:])
}
```

## 4. 性能优化规范

### 4.1 列表性能

```swift
// ✅ 正确 - 使用 LazyVStack
ScrollView(.horizontal) {
    LazyHStack(spacing: 12) {
        ForEach(clips) { clip in
            ClipCardView(item: clip)
        }
    }
}

// ✅ 正确 - 图片异步加载
AsyncImage(url: imageURL) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

### 4.2 搜索优化

```swift
// ✅ 正确 - 使用防抖
$searchText
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink { [weak self] text in
        self?.performSearch(text)
    }
    .store(in: &cancellables)
```

## 5. 测试规范

### 5.1 单元测试命名

```swift
class ContentAnalyzerTests: XCTestCase {
    
    func testDetectURL() {
        // Given
        let analyzer = ContentAnalyzer.shared
        let text = "https://github.com"
        
        // When
        let category = analyzer.detectTextCategory(text)
        
        // Then
        XCTAssertEqual(category, .link)
    }
    
    func testDetectCodeBlock() {
        // Given
        let code = """
        func hello() {
            print("Hello")
        }
        """
        
        // When
        let isCode = analyzer.isCodeBlock(code)
        
        // Then
        XCTAssertTrue(isCode)
    }
}
```

### 5.2 UI 测试

```swift
func testHorizontalScroll() {
    // Given
        let app = XCUIApplication()
        app.launch()
        
    // When
        app.typeKey("v", modifierFlags: [.command, .option])
        
    // Then
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)
}
```

## 6. 文档规范

### 6.1 README 结构

```markdown
# ClipNote

## 简介
...

## 功能特性
...

## 安装
...

## 使用方法
...

## 开发
...

## 许可证
...
```

### 6.2 CHANGELOG 格式

```markdown
# Changelog

## [1.0.0] - 2026-05-31

### Added
- 剪贴板监听功能
- 智能分类
- 点击即粘贴

### Fixed
- 修复 XX 问题

### Changed
- 优化 XX 性能
```

## 7. Git 规范

### 7.1 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

类型：
- `feat`: 新功能
- `fix`: 修复
- `docs`: 文档
- `style`: 格式
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建/工具

### 7.2 分支命名

```
main          - 主分支
develop       - 开发分支
feature/xxx   - 功能分支
fix/xxx       - 修复分支
release/xxx   - 发布分支
```

## 8. 代码审查清单

### 8.1 功能性

- [ ] 功能是否按需求实现
- [ ] 边界情况是否处理
- [ ] 错误处理是否完善

### 8.2 性能

- [ ] 是否有内存泄漏
- [ ] 是否有性能瓶颈
- [ ] 是否有不必要的计算

### 8.3 可维护性

- [ ] 代码是否清晰易读
- [ ] 是否有适当的注释
- [ ] 是否遵循编码规范

### 8.4 安全性

- [ ] 是否处理敏感数据
- [ ] 是否有权限问题
- [ ] 是否有数据泄露风险
