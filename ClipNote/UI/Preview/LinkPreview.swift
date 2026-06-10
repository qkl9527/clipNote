import SwiftUI

/// 链接预览组件
struct LinkPreview: View {
    let url: String
    @State private var siteTitle: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.purple)
                Text("链接")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                Button(action: copyURL) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("复制")
                    }
                    .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            Text(url)
                .font(.body)
                .foregroundColor(.blue)
                .textSelection(.enabled)
            
            if let title = siteTitle {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .onAppear {
            fetchSiteTitle()
        }
    }
    
    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url, forType: .string)
    }
    
    private func fetchSiteTitle() {
        guard let urlObj = URL(string: url) else { return }
        
        isLoading = true
        URLSession.shared.dataTask(with: urlObj) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data,
                   let html = String(data: data, encoding: .utf8) {
                    siteTitle = extractTitle(from: html)
                }
            }
        }.resume()
    }
    
    private func extractTitle(from html: String) -> String? {
        let pattern = "<title[^>]*>([^<]+)</title>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)) else {
            return nil
        }
        
        let range = Range(match.range(at: 1), in: html)!
        return String(html[range])
    }
}

#Preview {
    LinkPreview(url: "https://github.com/user/repo")
        .frame(width: 400, height: 150)
}
