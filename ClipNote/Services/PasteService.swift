import Foundation
import AppKit
import ApplicationServices

class PasteService {
    static let shared = PasteService()

    private var targetApplication: NSRunningApplication?

    private init() {}

    func rememberCurrentTargetApplication() {
        guard let application = NSWorkspace.shared.frontmostApplication else { return }
        guard application.processIdentifier != NSRunningApplication.current.processIdentifier else { return }
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            guard application.bundleIdentifier != bundleIdentifier else { return }
        }
        targetApplication = application
    }

    func pasteToActiveApp(item: ClipItem) {
        writeToPasteboard(item: item)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if self.checkAccessibility() {
                self.activateTargetApplication()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    self.simulateCommandV()
                }
            } else {
                AccessibilityHelper.showAccessibilityAlert()
            }
        }
    }

    private func writeToPasteboard(item: ClipItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.category {
        case .image, .imageBase64:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: .tiff)
            } else {
                pasteboard.setString(item.content, forType: .string)
            }

        case .richText:
            if let rtfData = item.rawRTF {
                pasteboard.setData(rtfData, forType: .rtf)
            } else {
                pasteboard.setString(item.content, forType: .string)
            }

        case .html:
            if let htmlData = item.rawHTML {
                pasteboard.setData(htmlData, forType: .html)
            } else {
                pasteboard.setString(item.content, forType: .string)
            }

        case .link:
            if let url = URL(string: item.content) {
                pasteboard.writeObjects([url as NSURL])
            } else {
                pasteboard.setString(item.content, forType: .string)
            }

        default:
            pasteboard.setString(item.content, forType: .string)
        }
    }

    func checkAccessibility() -> Bool {
        AccessibilityHelper.isAccessibilityEnabled()
    }

    private func activateTargetApplication() {
        guard let targetApplication, !targetApplication.isTerminated else { return }
        targetApplication.activate(options: [.activateIgnoringOtherApps])
    }

    private func simulateCommandV() {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            print("无法创建事件源")
            return
        }

        let vKeyCode: CGKeyCode = 0x09

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true) else {
            print("无法创建 Key Down 事件")
            return
        }
        keyDown.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)

        guard let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false) else {
            print("无法创建 Key Up 事件")
            return
        }
        keyUp.flags = .maskCommand
        keyUp.post(tap: .cghidEventTap)
    }

    func requestAccessibility() {
        AccessibilityHelper.requestAccessibility()
    }
}
