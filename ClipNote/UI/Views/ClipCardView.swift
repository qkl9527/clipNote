import SwiftUI
import UniformTypeIdentifiers

struct ClipCardView: View {
    let item: ClipItem
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            contentPreview
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            footer
        }
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? ClipNoteTheme.primary : ClipNoteTheme.hairline, lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: ClipNoteTheme.ink.opacity(isHovering ? 0.13 : 0.07), radius: isHovering ? 10 : 5, y: isHovering ? 5 : 2)
        .scaleEffect(isHovering ? 1.015 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(perform: onTap)
        .onHover { hovering in
            isHovering = hovering
        }
        .onDrag {
            dragItemProvider()
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(categoryColor.opacity(0.16))
                Image(systemName: item.category.icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(categoryColor)
            }
            .frame(width: 20, height: 20)

            Text(item.category.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isDarkPreview ? ClipNoteTheme.onDark : ClipNoteTheme.body)
                .lineLimit(1)

            Spacer()

            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundColor(ClipNoteTheme.accentAmber)
            }

            if item.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(ClipNoteTheme.accentAmber)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 7) {
            Rectangle()
                .fill(isDarkPreview ? Color.white.opacity(0.08) : ClipNoteTheme.hairlineSoft)
                .frame(height: 1)

            HStack(spacing: 6) {
                Text(item.formattedTime)
                    .font(.caption2)
                    .foregroundColor(isDarkPreview ? ClipNoteTheme.onDarkSoft : ClipNoteTheme.muted)

                Text(item.formattedSize)
                    .font(.caption2)
                    .foregroundColor(isDarkPreview ? ClipNoteTheme.onDarkSoft.opacity(0.8) : ClipNoteTheme.mutedSoft)

                Spacer()

                if let sourceApp = item.sourceApp {
                    Text(sourceApp)
                        .font(.caption2)
                        .foregroundColor(isDarkPreview ? ClipNoteTheme.onDarkSoft : ClipNoteTheme.muted)
                        .lineLimit(1)
                }
            }
        }
    }

    @ViewBuilder
    private var contentPreview: some View {
        switch item.category {
        case .code:
            darkTextPreview(label: item.codeLanguage ?? "CODE")

        case .html:
            darkTextPreview(label: "HTML")

        case .text:
            Text(item.previewText(maxLines: 5))
                .font(.system(size: 12))
                .lineLimit(5)
                .foregroundColor(ClipNoteTheme.body)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .link:
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText(maxLines: 4))
                    .font(.system(size: 12))
                    .lineLimit(4)
                    .foregroundColor(ClipNoteTheme.primaryActive)
                    .lineSpacing(3)

                Text("LINK")
                    .font(.caption2)
                    .foregroundColor(ClipNoteTheme.muted)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(ClipNoteTheme.surfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }

        case .richText:
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText(maxLines: 3))
                    .font(.system(size: 12))
                    .lineLimit(3)
                    .foregroundColor(ClipNoteTheme.body)
                    .lineSpacing(3)

                Text("RTF")
                    .font(.caption2)
                    .foregroundColor(ClipNoteTheme.muted)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(ClipNoteTheme.surfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }

        case .image:
            if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 180)
                    .background(ClipNoteTheme.surfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            } else {
                imagePlaceholder
            }

        case .file:
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(ClipNoteTheme.muted)

                Text(item.content)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .foregroundColor(ClipNoteTheme.body)
            }
        }
    }

    private func darkTextPreview(label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Circle().fill(Color(hex: 0xc64545)).frame(width: 5, height: 5)
                Circle().fill(ClipNoteTheme.accentAmber).frame(width: 5, height: 5)
                Circle().fill(ClipNoteTheme.accentTeal).frame(width: 5, height: 5)

                Spacer()

                Text(label.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(ClipNoteTheme.onDarkSoft)
            }

            Text(item.previewText(maxLines: 7))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(ClipNoteTheme.onDark)
                .lineLimit(7)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
        .background(ClipNoteTheme.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var imagePlaceholder: some View {
        VStack {
            Spacer()
            Image(systemName: "photo")
                .font(.title)
                .foregroundColor(ClipNoteTheme.muted)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(ClipNoteTheme.surfaceSoft)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private var cardBackground: some View {
        Group {
            if isDarkPreview {
                ClipNoteTheme.surfaceDarkElevated
            } else if isSelected {
                ClipNoteTheme.surfaceCard
            } else if isHovering {
                ClipNoteTheme.surfaceSoft
            } else {
                ClipNoteTheme.canvas
            }
        }
    }

    private var categoryColor: Color {
        ClipNoteTheme.categoryColor(item.category)
    }

    private var isDarkPreview: Bool {
        item.category == .code || item.category == .html
    }

    private func dragItemProvider() -> NSItemProvider {
        switch item.category {
        case .link:
            return urlDragItemProvider()

        case .html:
            return dataDragItemProvider(data: item.rawHTML, type: .html)

        case .richText:
            return dataDragItemProvider(data: item.rawRTF, type: .rtf)

        case .image:
            if let imageData = item.imageData, let image = NSImage(data: imageData) {
                return NSItemProvider(object: image)
            }
            return textDragItemProvider()

        case .file:
            return fileDragItemProvider()

        case .text, .code:
            return textDragItemProvider()
        }
    }

    private func textDragItemProvider() -> NSItemProvider {
        NSItemProvider(object: item.content as NSString)
    }

    private func urlDragItemProvider() -> NSItemProvider {
        let provider = textDragItemProvider()
        if let url = URL(string: item.content) {
            provider.registerObject(url as NSURL, visibility: .all)
        }
        return provider
    }

    private func dataDragItemProvider(data: Data?, type: UTType) -> NSItemProvider {
        let provider = textDragItemProvider()
        if let data {
            provider.registerDataRepresentation(forTypeIdentifier: type.identifier, visibility: .all) { completion in
                completion(data, nil)
                return nil
            }
        }
        return provider
    }

    private func fileDragItemProvider() -> NSItemProvider {
        let urlString = item.fileURL ?? item.content
        if let url = URL(string: urlString), url.isFileURL {
            return NSItemProvider(object: url as NSURL)
        }
        if urlString.hasPrefix("/") {
            return NSItemProvider(object: URL(fileURLWithPath: urlString) as NSURL)
        }
        return textDragItemProvider()
    }
}

#Preview {
    ClipCardView(
        item: ClipItem(
            content: "这是一段测试文本内容，用于预览卡片效果。",
            category: .text,
            sourceApp: "Safari"
        ),
        isSelected: false,
        onTap: {}
    )
    .frame(width: 200, height: 280)
}
