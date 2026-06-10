import AppKit

enum AppIconProvider {
    static var image: NSImage {
        NSApp.applicationIconImage
    }
}
