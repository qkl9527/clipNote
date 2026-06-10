# ClipNote

ClipNote is a native macOS clipboard manager built with SwiftUI and AppKit. It monitors the system clipboard in the background, classifies copied content automatically, stores clipboard history locally, and lets you bring up a floating panel with a global shortcut. Click any card to paste it back into the current app.

Repository: [https://github.com/qkl9527/clipNote](https://github.com/qkl9527/clipNote)

## Features

- Native macOS menu bar app. The Dock icon is hidden by default.
- Global shortcut `⌥⌘V` to show or hide the clipboard panel.
- Clipboard monitoring with a default 0.5 second polling interval.
- Automatic classification into 10 content types: plain text, links, code, Markdown, HTML, rich text, image URLs, Base64 images, images, and files.
- Horizontal card-based history panel with search, category filters, and click-to-paste.
- Dark preview surfaces for code, Markdown, and HTML cards for better visual distinction.
- Local SQLite storage powered by GRDB.
- Data management with max item count, JSON export, and a confirmation dialog before clearing all records.
- macOS-style settings window with a left sidebar and right detail pane.
- Configurable default panel size. The default is 900 wide and 430 high.
- Optional category shortcut labels in the main panel.
- Repository and issue tracker links are available in the About settings page.

## Requirements

- macOS 14.0 or later
- Xcode 15 or later
- Swift 5.9 or later

## Accessibility Permission

ClipNote needs Accessibility permission to paste selected clipboard content into the current app. If the permission is missing, ClipNote will prompt you when you try to paste from a card.

Permission path:

```text
System Settings -> Privacy & Security -> Accessibility -> ClipNote
```

If ClipNote is already enabled but paste still does not work, remove the old ClipNote entry from Accessibility and add the currently running app again.

## Getting Started

```bash
git clone https://github.com/qkl9527/clipNote.git
cd clipNote/ClipNote
open Package.swift
```

Open the package in Xcode, select the `ClipNote` scheme, and run it.

You can also build from the command line:

```bash
cd ClipNote
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -scheme ClipNote -destination 'platform=macOS' build
```

If `xcode-select` points to Command Line Tools instead of the full Xcode installation, `swift build` may fail because a third-party dependency uses SwiftUI Preview macros. Building with the full Xcode toolchain is recommended.

## Usage

1. Launch ClipNote.
2. Copy text, links, code, images, or files.
3. Press `⌥⌘V` to open the floating panel.
4. Search or filter by category to find an item.
5. Click a card. ClipNote writes the content to the system clipboard and simulates `⌘V` in the current app.

## Shortcuts

| Shortcut | Action |
| --- | --- |
| `⌥⌘V` | Show or hide the main panel |
| `⌘K` | Clear search |
| `⌘⌥0` | Select all categories |
| `⌘⌥1-9` | Select a category |
| `Enter` | Paste the selected item |
| `⌘C` | Copy to clipboard |
| `Esc` | Close the panel |
| `←` / `→` | Move between cards |

The `⌘⌥number` labels shown after category names can be disabled in Settings.

## Settings

The settings window contains five sections:

| Section | Contents |
| --- | --- |
| General | Launch at login, Dock icon, menu bar icon, category shortcut labels, default panel size, polling interval |
| Shortcuts | Global shortcut recorder, shortcut reference, category shortcut label toggle |
| Data | Max saved items, current item count, clear all records, JSON export |
| Permissions | Accessibility status, open System Settings, recheck permission, capability checks |
| About | App information, version, repository link, GitHub Issues link, privacy note |

Clearing all records requires a confirmation dialog.

## Supported Content Types

| Type | Description |
| --- | --- |
| Plain text | Regular text content |
| Link | `http`, `https`, or `ftp` URLs |
| Code | Common code snippets and language patterns |
| Markdown | Markdown source text |
| HTML | HTML source or HTML clipboard data |
| Rich text | RTF / RTFD content |
| Image URL | A URL pointing to a remote image |
| Base64 image | `data:image/...;base64,...` content |
| Image | Binary image data from the clipboard |
| File | File URLs or paths copied from Finder |

## Tech Stack

- SwiftUI: main UI, settings, and reusable components
- AppKit: menu bar, NSPanel, system permissions, and paste events
- KeyboardShortcuts: global shortcut recording and registration
- GRDB.swift: SQLite storage and querying
- Highlightr: code syntax highlighting
- WebKit: HTML and Markdown preview support

## Project Structure

```text
ClipNote/
├── App/                  # App entry, AppDelegate, settings window manager
├── Models/               # ClipItem, ClipCategory
├── Services/             # Clipboard monitoring, analysis, storage, paste service
├── UI/
│   ├── Design/           # Design tokens and logo component
│   ├── Panel/            # FloatingPanel and PanelManager
│   ├── Preview/          # Content preview views
│   ├── Settings/         # Settings window
│   └── Views/            # Main window, search, categories, cards
├── Utils/                # Accessibility, icon, highlighting, Markdown helpers
├── Assets.xcassets       # App icon assets
├── Info.plist            # macOS app configuration
├── Package.swift         # Swift Package configuration
└── ClipNote.entitlements # Entitlements
```

## Package and App Identifiers

- Swift Package: `ClipNote`
- Executable target: `ClipNote`
- Bundle Identifier: `com.qkl9527.clipnote`
- Minimum system version: macOS 14.0
- App mode: menu bar app, `LSUIElement = true`

If you change the Bundle Identifier, macOS will treat it as a different app and Accessibility permission may need to be granted again.

## Design Concepts

UI concept images are stored in:

```text
design/concepts/
```

The current UI follows the warm color direction from `design/DESIGN.md`, adapted for a native macOS app with system-friendly Chinese typography.

## Issues

Please report bugs and feature requests through GitHub Issues:

[https://github.com/qkl9527/clipNote/issues](https://github.com/qkl9527/clipNote/issues)

## License

MIT License
