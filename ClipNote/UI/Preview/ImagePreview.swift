import SwiftUI

/// 图片预览组件
struct ImagePreview: View {
    let imageData: Data?
    let imageURL: String?
    let category: ClipCategory
    
    @State private var nsImage: NSImage?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(.indigo)
                Text(imageInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                if let nsImage = nsImage {
                    Text("\(Int(nsImage.size.width))×\(Int(nsImage.size.height))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if let nsImage = nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .background(Color.white)
                    .cornerRadius(6)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                imagePlaceholder
            }
        }
        .padding()
        .onAppear {
            loadImage()
        }
    }
    
    private var imageInfo: String {
        switch category {
        case .image:
            return "图片"
        case .imageBase64:
            return "Base64 图片"
        case .imageUrl:
            return "图片链接"
        default:
            return "图片"
        }
    }
    
    private var imagePlaceholder: some View {
        VStack {
            Spacer()
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
    
    private func loadImage() {
        if let imageData = imageData {
            nsImage = NSImage(data: imageData)
        } else if let urlString = imageURL, let url = URL(string: urlString) {
            isLoading = true
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    isLoading = false
                    if let data = data {
                        nsImage = NSImage(data: data)
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    ImagePreview(imageData: nil, imageURL: nil, category: .image)
        .frame(width: 400, height: 300)
}
