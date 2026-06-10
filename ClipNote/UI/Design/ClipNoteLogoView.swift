import SwiftUI

struct ClipNoteLogoView: View {
    let size: CGFloat

    var body: some View {
        Image(nsImage: AppIconProvider.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: max(4, size * 0.22)))
            .overlay(
                RoundedRectangle(cornerRadius: max(4, size * 0.22))
                    .stroke(ClipNoteTheme.hairline, lineWidth: 1)
            )
    }
}
