# ClipNote - 开发待办清单

## 优先级 P0 (必须完成)

### 基础设施
- [ ] 在 Xcode 创建项目并导入所有文件
- [ ] 添加 SPM 依赖 (KeyboardShortcuts, GRDB, Highlightr)
- [ ] 配置项目签名和权限
- [ ] 修复所有编译错误
- [ ] 通过基础功能测试

### 核心功能验证
- [ ] 测试剪贴板监听是否正常工作
- [ ] 测试内容分类是否准确
- [ ] 测试点击粘贴功能
- [ ] 测试 Accessibility 权限流程

---

## 优先级 P1 (重要)

### 功能增强
- [ ] 优化图片预览性能（大图压缩）
- [ ] 添加键盘导航（← → 切换卡片）
- [ ] 添加 Enter 键粘贴支持
- [ ] 完善错误处理和用户提示

### UI 优化
- [ ] 优化面板显示/隐藏动画
- [ ] 添加卡片选中态视觉反馈
- [ ] 优化搜索结果为空时的显示
- [ ] 添加加载状态指示器

### 稳定性
- [ ] 处理数据库损坏情况
- [ ] 处理图片加载失败
- [ ] 处理 Accessibility 权限被撤销
- [ ] 添加崩溃日志记录

---

## 优先级 P2 (可选)

### 新功能
- [ ] 添加 iCloud 同步支持
- [ ] 添加 PIN 加密功能
- [ ] 添加快捷键粘贴（⌘1-9）
- [ ] 添加拖拽粘贴支持
- [ ] 添加收藏功能
- [ ] 添加固定功能

### 国际化
- [ ] 添加英文支持
- [ ] 添加日文支持
- [ ] 支持 RTL 语言

### 导出功能
- [ ] 添加 CSV 导出
- [ ] 添加 Markdown 导出
- [ ] 添加纯文本导出

---

## 优先级 P3 (未来)

### 高级功能
- [ ] 添加 OCR 图片文字识别
- [ ] 添加 AI 智能分类
- [ ] 添加剪贴板历史云同步
- [ ] 添加多设备同步
- [ ] 添加团队共享

### 平台扩展
- [ ] iOS 版本
- [ ] Windows 版本
- [ ] 浏览器扩展

---

## 技术债务

### 代码质量
- [ ] 添加单元测试（覆盖率 > 80%）
- [ ] 添加 UI 测试
- [ ] 重构 ContentAnalyzer（拆分类检测逻辑）
- [ ] 优化 StorageManager（添加事务支持）

### 文档完善
- [ ] 完善 API 文档
- [ ] 添加代码注释
- [ ] 更新 README
- [ ] 编写用户手册

### 性能优化
- [ ] 优化数据库查询
- [ ] 减少内存占用
- [ ] 优化图片处理
- [ ] 添加缓存机制

---

## 已完成

### 2026-05-31
- [x] 创建项目目录结构
- [x] 编写 Package.swift
- [x] 配置 Info.plist
- [x] 实现 ClipItem 数据模型
- [x] 实现 ClipCategory 分类枚举
- [x] 实现 ClipboardMonitor 剪贴板监听
- [x] 实现 ContentAnalyzer 智能分类
- [x] 实现 StorageManager SQLite 存储
- [x] 实现 PasteService 粘贴服务
- [x] 实现 ClipboardManager 统一管理
- [x] 实现 FloatingPanel 浮动面板
- [x] 实现 PanelManager 面板管理
- [x] 实现 ContentView 主视图
- [x] 实现 HorizontalCardList 水平列表
- [x] 实现 ClipCardView 卡片组件
- [x] 实现 SearchBar 搜索栏
- [x] 实现 CategoryTabs 分类标签
- [x] 实现 SettingsView 设置页面
- [x] 实现 TextPreview 文本预览
- [x] 实现 CodePreview 代码预览
- [x] 实现 MarkdownPreview Markdown 预览
- [x] 实现 ImagePreview 图片预览
- [x] 实现 HTMLPreview HTML 预览
- [x] 实现 LinkPreview 链接预览
- [x] 实现 AccessibilityHelper 权限工具
- [x] 实现 CodeHighlighter 代码高亮
- [x] 实现 MarkdownRenderer Markdown 渲染
- [x] 编写架构设计文档
- [x] 编写功能规格文档
- [x] 编写编码规范文档
- [x] 编写开发进展文档
- [x] 编写 README

---

## 下一步行动

1. 在 Xcode 中创建项目并导入文件
2. 添加 SPM 依赖
3. 编译修复错误
4. 运行测试核心功能
5. 根据测试结果优化
