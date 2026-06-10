# ClipNote

ClipNote 是一个原生 macOS 剪贴板管理工具，使用 SwiftUI + AppKit 构建。它会在后台监听系统剪贴板，自动分类和保存复制内容，并通过全局快捷键快速唤出浮动面板，点击卡片即可粘贴到当前应用。

项目地址：[https://github.com/qkl9527/clipNote](https://github.com/qkl9527/clipNote)

## 功能特性

- 原生 macOS 菜单栏应用，默认不显示 Dock 图标。
- 全局快捷键 `⌥⌘V` 唤出或隐藏剪贴板面板。
- 自动监听剪贴板变化，默认 0.5 秒轮询。
- 自动识别 10 类内容：纯文本、链接、代码、Markdown、HTML、富文本、图片链接、Base64 图片、图片、文件。
- 横向卡片流展示历史记录，支持搜索、分类筛选和点击粘贴。
- 代码、Markdown、HTML 卡片使用深色预览面，提升可读性和识别度。
- 本机 SQLite 存储，使用 GRDB 管理数据。
- 支持清空记录二次确认、JSON 导出、最大保存条目数配置。
- 设置页采用 macOS 风格左侧导航 + 右侧内容布局。
- 支持配置默认窗口宽高，默认宽度 900、高度 430。
- 支持开关主窗口分类快捷键提示。
- 项目地址和问题反馈入口内置在设置页“关于”中。

## 系统要求

- macOS 14.0 或更高版本
- Xcode 15 或更高版本
- Swift 5.9 或更高版本

## 权限说明

ClipNote 需要辅助功能权限才能把选中的剪贴板内容粘贴到当前应用。首次使用点击卡片粘贴时，如果尚未授权，应用会提示打开系统设置。

授权路径：

```text
系统设置 -> 隐私与安全性 -> 辅助功能 -> ClipNote
```

如果已经授权但仍无法粘贴，可以在辅助功能列表中删除旧的 ClipNote 条目，然后重新添加当前运行的 ClipNote。

## 快速开始

```bash
git clone https://github.com/qkl9527/clipNote.git
cd clipNote/ClipNote
open Package.swift
```

在 Xcode 中打开后，选择 `ClipNote` scheme，然后运行。

也可以使用命令行构建：

```bash
cd ClipNote
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -scheme ClipNote -destination 'platform=macOS' build
```

如果当前 `xcode-select` 指向 Command Line Tools，直接执行 `swift build` 可能会因为第三方依赖中的 SwiftUI Preview 宏而失败。建议使用完整 Xcode 环境构建。

## 使用方式

1. 启动 ClipNote。
2. 复制任意文本、链接、代码、图片或文件。
3. 按 `⌥⌘V` 唤出浮动面板。
4. 搜索或选择分类定位记录。
5. 点击卡片，ClipNote 会写入系统剪贴板并模拟 `⌘V` 粘贴到当前应用。

## 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `⌥⌘V` | 唤出或隐藏主面板 |
| `⌘K` | 清空搜索 |
| `⌘⌥0` | 切换到全部分类 |
| `⌘⌥1-9` | 切换到对应分类 |
| `Enter` | 粘贴选中内容 |
| `⌘C` | 复制到剪贴板 |
| `Esc` | 关闭面板 |
| `←` / `→` | 切换选中卡片 |

分类名称后的 `⌘⌥数字` 提示可以在设置页中关闭。

## 设置项

设置页包含 5 个子页面：

| 页面 | 内容 |
| --- | --- |
| 通用 | 开机自启动、Dock 图标、菜单栏图标、分类快捷键提示、默认窗口宽高、轮询间隔 |
| 快捷键 | 全局唤出快捷键录制器、快捷键说明、分类快捷键提示开关 |
| 数据 | 最大保存条目数、当前条目数、清空所有记录、导出 JSON |
| 权限 | 辅助功能授权状态、打开系统设置、重新检查、能力检查 |
| 关于 | 应用信息、版本、项目地址、GitHub Issues、隐私说明 |

清空所有记录会弹出二次确认。

## 支持的内容类型

| 类型 | 说明 |
| --- | --- |
| 纯文本 | 普通文本内容 |
| 链接 | `http`、`https`、`ftp` 链接 |
| 代码 | 自动识别常见代码片段和语言特征 |
| Markdown | Markdown 源文本 |
| HTML | HTML 源码或 HTML 剪贴板数据 |
| 富文本 | RTF / RTFD 内容 |
| 图片链接 | 指向远程图片的 URL |
| Base64 图片 | `data:image/...;base64,...` 内容 |
| 图片 | 剪贴板中的图片二进制数据 |
| 文件 | Finder 复制的文件 URL 或路径 |

## 技术栈

- SwiftUI：主界面、设置页和组件
- AppKit：菜单栏、NSPanel、系统权限和粘贴事件
- KeyboardShortcuts：全局快捷键录制和注册
- GRDB.swift：SQLite 存储和查询
- Highlightr：代码语法高亮
- WebKit：HTML / Markdown 预览相关能力

## 项目结构

```text
ClipNote/
├── App/                  # 应用入口、AppDelegate、设置窗口管理
├── Models/               # ClipItem、ClipCategory
├── Services/             # 剪贴板监听、内容分析、存储、粘贴服务
├── UI/
│   ├── Design/           # 设计 token、Logo 组件
│   ├── Panel/            # FloatingPanel、PanelManager
│   ├── Preview/          # 各类内容预览
│   ├── Settings/         # 设置页
│   └── Views/            # 主窗口视图、搜索栏、分类、卡片
├── Utils/                # 权限、图标、代码高亮、Markdown 渲染工具
├── Assets.xcassets       # 应用图标资源
├── Info.plist            # macOS App 配置
├── Package.swift         # Swift Package 配置
└── ClipNote.entitlements # 权限配置
```

## 包名与标识

- Swift Package：`ClipNote`
- 可执行目标：`ClipNote`
- Bundle Identifier：`com.qkl9527.clipnote`
- 最低系统版本：macOS 14.0
- 应用类型：菜单栏应用，`LSUIElement = true`

修改 Bundle Identifier 后，macOS 会把它视作一个新应用，辅助功能权限可能需要重新授权。

## 设计稿

UI 视觉概念图保存在：

```text
design/concepts/
```

当前设计参考 `design/DESIGN.md` 的暖色系，并针对 macOS 原生应用改为系统中文字体体系。

## 问题反馈

请通过 GitHub Issues 提交问题和建议：

[https://github.com/qkl9527/clipNote/issues](https://github.com/qkl9527/clipNote/issues)

## 许可证

MIT License
