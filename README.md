# ClipNote

轻量级 macOS 剪贴板管理工具，支持快速唤出预览、一键粘贴。

## 功能特性

- ⚡ **轻量快速** - 原生 Swift 开发，启动迅速
- 🎯 **智能分类** - 自动识别 10 种内容类型
- 📋 **点击即粘贴** - 选中即可粘贴到焦点窗口
- 🔍 **全文搜索** - FTS5 索引，毫秒级搜索
- 🔒 **隐私优先** - 本地存储，跳过密码管理器内容
- 🎨 **水平滚动** - 卡片式展示，流畅滚动体验

## 支持的内容类型

| 类型 | 说明 |
|------|------|
| 纯文本 | 普通文本内容 |
| 链接 | http/https/ftp URL |
| 代码块 | 支持 10+ 语言语法高亮 |
| Markdown | 源码/预览切换 |
| HTML | 源码/WebView 预览 |
| 富文本 | RTF/RTFD 格式 |
| 图片 URL | 远程图片链接 |
| Base64 图片 | data:image/ 格式 |
| 图片 | TIFF/PNG 二进制数据 |
| 文件 | 文件路径 |

## 安装

### 方法一：从源码构建

```bash
# 克隆项目
git clone https://github.com/yourusername/ClipNote.git
cd ClipNote

# 打开 Xcode
open Package.swift

# 或者创建 Xcode 项目后导入文件
```

### 方法二：下载 Release

1. 下载最新 `.dmg` 文件
2. 拖动 ClipNote 到 Applications 文件夹
3. 首次运行需授权辅助功能权限

## 使用方法

### 基本操作

| 快捷键 | 功能 |
|--------|------|
| `⌥⌘V` | 唤出/隐藏面板 |
| `Enter` | 粘贴选中内容 |
| `⌘C` | 复制到剪贴板 |
| `⌘K` | 清空搜索 |
| `Esc` | 关闭面板 |
| `← →` | 切换选中卡片 |

### 首次使用

1. 启动 ClipNote
2. 授予辅助功能权限
   - 系统偏好设置 → 隐私与安全 → 辅助功能
   - 勾选 ClipNote
3. 按 `⌥⌘V` 唤出面板
4. 复制任意内容，会自动显示在面板中

### 搜索和筛选

1. 按 `⌥⌘V` 唤出面板
2. 在搜索栏输入关键词
3. 实时过滤显示匹配结果
4. 点击分类标签筛选特定类型

### 设置

1. 点击菜单栏图标
2. 选择"设置"
3. 自定义快捷键、轮询间隔等

## 开发

### 环境要求

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

### 依赖

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - 全局快捷键
- [GRDB.swift](https://github.com/groue/GRDB.swift) - SQLite 封装
- [Highlightr](https://github.com/raspu/Highlightr) - 代码高亮

### 构建

```bash
# 使用 Xcode
open Package.swift
# ⌘R 运行

# 使用命令行
swift build
swift run
```

### 项目结构

```
ClipNote/
├── App/                # 应用入口
├── Models/             # 数据模型
├── Services/           # 核心服务
├── UI/
│   ├── Panel/          # 浮动面板
│   ├── Views/          # 视图组件
│   ├── Preview/        # 内容预览
│   └── Settings/       # 设置页面
├── Utils/              # 工具类
└── Resources/          # 资源文件
```

## 文档

- [架构设计](docs/ARCHITECTURE.md)
- [功能规格](docs/FUNCTIONAL_SPEC.md)
- [编码规范](docs/CODING_STANDARDS.md)
- [开发进展](docs/PROGRESS.md)

## 贡献

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

MIT License

## 致谢

- [Maccy](https://github.com/p0deje/Maccy) - 灵感来源
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - 快捷键支持
- [GRDB.swift](https://github.com/groue/GRDB.swift) - 数据库支持
