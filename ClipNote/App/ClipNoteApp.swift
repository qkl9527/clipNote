import SwiftUI

@main
struct ClipNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clipboardManager = ClipboardManager.shared
    @StateObject private var storageManager = StorageManager.shared
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(clipboardManager)
                .environmentObject(storageManager)
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("设置...") {
                    NotificationCenter.default.post(name: .clipNoteOpenSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }
}
