# ClipNote - 开发进展文档

## 版本历史

### v1.0.0 (2026-05-31)

#### 已完成功能

##### Phase 0: 项目初始化 ✅
- [x] 创建 Xcode 项目结构
- [x] 配置 Package.swift (SPM 依赖)
- [x] 配置 Info.plist (LSUIElement=true)
- [x] 配置 entitlements

##### Phase 1: 数据模型 ✅
- [x] ClipItem 数据模型
- [x] ClipCategory 分类枚举 (10种类型)
- [x] SQLite 表结构设计
- [x] FTS5 全文索引

##### Phase 2: 核心引擎 ✅
- [x] ClipboardMonitor - 剪贴板监听
  - [x] Timer 0.5s 轮询
  - [x] changeCount 变化检测
  - [x] 密码管理器内容过滤
- [x] ContentAnalyzer - 智能分类
  - [x] 图片检测 (TIFF/PNG)
  - [x] 文件检测
  - [x] 富文本检测 (RTF/HTML)
  - [x] URL 检测
  - [x] 代码块检测 (多语言)
  - [x] Markdown 检测
  - [x] Base64 图片检测
  - [x] 代码语言自动识别
- [x] StorageManager - SQLite 存储
  - [x] GRDB 集成
  - [x] CRUD 操作
  - [x] 搜索和筛选
  - [x] 自动裁剪旧数据
- [x] ClipboardManager - 统一管理
  - [x] 发布者模式
  - [x] 筛选逻辑

##### Phase 3: 浮动面板 ✅
- [x] FloatingPanel - NSPanel 封装
  - [x] 浮动窗口级别
  - [x] 圆角设计
  - [x] 透明标题栏
  - [x] 居中显示
- [x] PanelManager - 面板管理
  - [x] 显示/隐藏切换
  - [x] 生命周期管理
- [x] ContentView - 主视图
  - [x] 搜索栏
  - [x] 分类标签
  - [x] 水平滚动列表
  - [x] 底部状态栏

##### Phase 4: 粘贴功能 ✅
- [x] PasteService - 粘贴服务
  - [x] 写入系统剪贴板
  - [x] 模拟 Cmd+V 键盘事件
  - [x] Accessibility 权限检测
  - [x] 权限引导对话框
  - [x] 不同内容类型的粘贴策略

##### Phase 5: UI 组件 ✅
- [x] 水平滚动卡片列表
- [x] ClipCardView - 卡片组件
  - [x] 分类图标
  - [x] 内容预览
  - [x] 悬停效果
  - [x] 选中状态
- [x] SearchBar - 搜索栏
- [x] CategoryTabs - 分类标签

##### Phase 6: 内容预览 ✅
- [x] TextPreview - 文本预览
- [x] CodePreview - 代码预览
  - [x] Highlightr 集成
  - [x] 语法高亮
- [x] MarkdownPreview - Markdown 预览
  - [x] 源码/预览切换
  - [x] HTML 渲染
- [x] ImagePreview - 图片预览
  - [x] 缩略图显示
  - [x] 远程图片加载
- [x] HTMLPreview - HTML 预览
  - [x] WebView 渲染
- [x] LinkPreview - 链接预览
  - [x] 网站标题获取

##### Phase 7: 设置页面 ✅
- [x] 通用设置
  - [x] 开机自启动
  - [x] 轮询间隔
  - [x] 辅助功能权限
- [x] 快捷键设置
  - [x] KeyboardShortcuts 集成
  - [x] 自定义快捷键
- [x] 数据管理
  - [x] 条目数量限制
  - [x] 清空数据
  - [x] JSON 导出
- [x] 关于页面

##### Phase 8: 工具类 ✅
- [x] AccessibilityHelper - 权限工具
- [x] CodeHighlighter - 代码高亮
- [x] MarkdownRenderer - Markdown 渲染

---

## 文件清单

### 核心文件 (27个 Swift 文件)

| 文件 | 行数 | 说明 |
|------|------|------|
| ClipNoteApp.swift | ~30 | 应用入口 |
| AppDelegate.swift | ~120 | 菜单栏 + 快捷键 |
| ClipItem.swift | ~100 | 数据模型 |
| ClipCategory.swift | ~70 | 分类枚举 |
| ClipboardMonitor.swift | ~100 | 剪贴板监听 |
| ClipboardManager.swift | ~80 | 统一管理 |
| ContentAnalyzer.swift | ~300 | 内容分析 |
| StorageManager.swift | ~200 | SQLite 存储 |
| PasteService.swift | ~100 | 粘贴服务 |
| FloatingPanel.swift | ~80 | 浮动面板 |
| PanelManager.swift | ~40 | 面板管理 |
| ContentView.swift | ~100 | 主视图 |
| HorizontalCardList.swift | ~60 | 水平列表 |
| ClipCardView.swift | ~150 | 卡片组件 |
| SearchBar.swift | ~60 | 搜索栏 |
| CategoryTabs.swift | ~60 | 分类标签 |
| SettingsView.swift | ~200 | 设置页面 |
| TextPreview.swift | ~40 | 文本预览 |
| CodePreview.swift | ~80 | 代码预览 |
| MarkdownPreview.swift | ~100 | Markdown 预览 |
| ImagePreview.swift | ~80 | 图片预览 |
| HTMLPreview.swift | ~60 | HTML 预览 |
| LinkPreview.swift | ~80 | 链接预览 |
| AccessibilityHelper.swift | ~40 | 权限工具 |
| CodeHighlighter.swift | ~80 | 代码高亮 |
| MarkdownRenderer.swift | ~100 | Markdown 渲染 |
| **总计** | **~2500** | - |

### 配置文件

| 文件 | 说明 |
|------|------|
| Package.swift | SPM 依赖配置 |
| Info.plist | 应用配置 |
| ClipNote.entitlements | 权限配置 |
| DESIGN.md | 产品设计文档 |
| ARCHITECTURE.md | 架构设计文档 |
| PROGRESS.md | 开发进展文档 |

---

## 待完成任务

### 优先级 P0 (必须)

- [ ] 在 Xcode 中创建项目并导入文件
- [ ] 添加 SPM 依赖 (KeyboardShortcuts, GRDB, Highlightr)
- [ ] 修复编译错误
- [ ] 测试核心功能

### 优先级 P1 (重要)

- [ ] 优化图片预览性能
- [ ] 添加键盘导航 (← → 切换卡片)
- [ ] 添加拖拽支持
- [ ] 完善错误处理

### 优先级 P2 (可选)

- [ ] 添加 iCloud 同步
- [ ] 添加 PIN 加密
- [ ] 添加快捷键粘贴 (⌘1-9)
- [ ] 添加多语言支持

---

## 技术债务

| 问题 | 优先级 | 说明 |
|------|--------|------|
| Highlightr 依赖 | P0 | 需要验证是否兼容 macOS 14 |
| NSPanel 焦点 | P1 | 面板显示时可能抢夺焦点 |
| 图片内存 | P1 | 大图片需要压缩处理 |
| 错误处理 | P2 | 部分地方缺少错误处理 |

---

## 测试计划

### 单元测试

- [ ] ContentAnalyzer 分类测试
- [ ] StorageManager CRUD 测试
- [ ] MarkdownRenderer 渲染测试

### 集成测试

- [ ] 剪贴板监听测试
- [ ] 粘贴功能测试
- [ ] 快捷键测试

### UI 测试

- [ ] 水平滚动测试
- [ ] 搜索功能测试
- [ ] 分类筛选测试

---

## 发布计划

### v1.0.0-beta (本周)
- 完成基础功能
- 内部测试

### v1.0.0 (下周)
- 修复 bug
- 发布 GitHub Release

### v1.1.0 (下个月)
- iCloud 同步
- 更多功能
