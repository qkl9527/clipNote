# AGENTS.md

## Project Overview

ClipNote is a native macOS clipboard manager (SwiftUI + AppKit). It monitors the clipboard, auto-categorizes content into 10 types, and allows click-to-paste into any focused window.

**Status**: Early development. Source files created but no Xcode project yet. Code has not been compiled.

## Build & Run

```bash
# Project is at ClipNote/ with SPM Package.swift
cd ClipNote

# Option 1: Open in Xcode (recommended for macOS app)
open Package.swift   # then ⌘R

# Option 2: CLI (limited - won't have proper macOS app behavior)
swift build
swift run
```

**Requirements**: macOS 14+, Xcode 15+, Swift 5.9+

**SPM Dependencies** (add via Xcode → File → Add Package Dependencies):
- `KeyboardShortcuts` (sindresorhus) — global hotkey registration
- `GRDB.swift` (groue) — SQLite with FTS5
- `Highlightr` (raspu) — code syntax highlighting (in Package.swift but not yet in targets)

## Critical Setup Notes

- **Info.plist**: `LSUIElement = true` (no Dock icon, menu-bar-only app)
- **Accessibility permission**: Required for paste-to-app via `CGEvent` simulation. App won't paste without it. Guide user to System Settings → Privacy & Security → Accessibility.
- **Hotkey**: `⌥⌘V` toggles the floating panel (defined in `AppDelegate.swift:82`)
- **No Xcode project**: Source files exist at `ClipNote/` but `.xcodeproj` has not been created. Agent must create one and import files.

## Architecture

Entry: `ClipNoteApp.swift` → `AppDelegate.swift` (menu bar + hotkey)

Key services:
- `ClipboardMonitor` — polls `NSPasteboard.changeCount` every 0.5s
- `ContentAnalyzer` — classifies into ClipCategory (text/link/code/markdown/html/richText/imageUrl/imageBase64/image/file)
- `StorageManager` — GRDB SQLite + FTS5 full-text search
- `PasteService` — writes to pasteboard, hides panel, simulates `Cmd+V` via `CGEvent`
- `PanelManager` → `FloatingPanel` (NSPanel, `.floating` level, 900×400)

UI flow: `ContentView` → `HorizontalCardList` → `ClipCardView` (horizontal scroll, click = paste)

## Conventions

- All UI in SwiftUI except `FloatingPanel` (NSPanel subclass) and `AppDelegate`
- `@StateObject` / `@EnvironmentObject` for state management
- GRDB for persistence (not Core Data)
- Chinese UI text throughout (app is Chinese-localized)
- No comments in code (per project style)
