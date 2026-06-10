import SwiftUI

enum ClipNoteTheme {
    static let primary = Color(hex: 0xcc785c)
    static let primaryActive = Color(hex: 0xa9583e)
    static let ink = Color(hex: 0x141413)
    static let body = Color(hex: 0x3d3d3a)
    static let muted = Color(hex: 0x6c6a64)
    static let mutedSoft = Color(hex: 0x8e8b82)
    static let hairline = Color(hex: 0xe6dfd8)
    static let hairlineSoft = Color(hex: 0xebe6df)
    static let canvas = Color(hex: 0xfaf9f5)
    static let surfaceSoft = Color(hex: 0xf5f0e8)
    static let surfaceCard = Color(hex: 0xefe9de)
    static let surfaceCreamStrong = Color(hex: 0xe8e0d2)
    static let surfaceDark = Color(hex: 0x181715)
    static let surfaceDarkElevated = Color(hex: 0x252320)
    static let surfaceDarkSoft = Color(hex: 0x1f1e1b)
    static let onDark = Color(hex: 0xfaf9f5)
    static let onDarkSoft = Color(hex: 0xa09d96)
    static let accentTeal = Color(hex: 0x5db8a6)
    static let accentAmber = Color(hex: 0xe8a55a)
    static let success = Color(hex: 0x5db872)
    static let warning = Color(hex: 0xd4a017)
    static let error = Color(hex: 0xc64545)

    static func categoryColor(_ category: ClipCategory) -> Color {
        switch category {
        case .text: return primary
        case .link: return Color(hex: 0x8f6ab8)
        case .code: return accentTeal
        case .html: return Color(hex: 0xc95f5f)
        case .richText: return Color(hex: 0xb56f95)
        case .image: return Color(hex: 0x6f83bd)
        case .file: return muted
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}
