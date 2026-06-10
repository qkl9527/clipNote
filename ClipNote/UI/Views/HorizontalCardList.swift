import SwiftUI
import AppKit

struct HorizontalCardList: View {
    let clips: [ClipItem]
    let onPaste: (ClipItem) -> Void
    
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            if clips.isEmpty {
                emptyStateView
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
                        ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                            ClipCardView(
                                item: clip,
                                isSelected: selectedIndex == index,
                                onTap: {
                                    selectedIndex = index
                                    onPaste(clip)
                                }
                            )
                            .frame(width: 200, height: 280)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .background(AutoHidingScrollViewConfigurator())
            }
        }
        .background(ClipNoteTheme.canvas)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(ClipNoteTheme.primary.opacity(0.72))
            
            Text("暂无剪贴板记录")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(ClipNoteTheme.ink)
            
            Text("复制内容后会自动显示在这里")
                .font(.system(size: 13))
                .foregroundColor(ClipNoteTheme.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ClipNoteTheme.canvas)
    }
}

#Preview {
    HorizontalCardList(clips: [], onPaste: { _ in })
        .frame(width: 900, height: 400)
}

private struct AutoHidingScrollViewConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            configureScrollView(from: view)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configureScrollView(from: nsView)
        }
    }

    private func configureScrollView(from view: NSView) {
        guard let scrollView = findScrollView(from: view) else { return }
        scrollView.scrollerStyle = .overlay
        scrollView.autohidesScrollers = true
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
    }

    private func findScrollView(from view: NSView) -> NSScrollView? {
        if let scrollView = view.enclosingScrollView {
            return scrollView
        }

        var current = view.superview
        while let view = current {
            if let scrollView = view as? NSScrollView {
                return scrollView
            }
            current = view.superview
        }

        return nil
    }
}
