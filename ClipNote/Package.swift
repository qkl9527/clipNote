// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipNote",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ClipNote", targets: ["ClipNote"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "2.4.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ClipNote",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Highlightr", package: "Highlightr")
            ],
            path: ".",
            exclude: [
                "Info.plist",
                "ClipNote.entitlements",
                "script",
                "dist"
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Security"),
            ]
        )
    ]
)
