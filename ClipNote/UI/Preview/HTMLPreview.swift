import SwiftUI
import WebKit

/// HTML 预览组件
struct HTMLPreview: View {
    let content: String
    @State private var showPreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.red)
                Text("HTML")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                Picker("", selection: $showPreview) {
                    Text("源码").tag(false)
                    Text("预览").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            
            if showPreview {
                HTMLWebView(html: content)
                    .background(Color.white)
                    .cornerRadius(6)
            } else {
                ScrollView {
                    Text(content)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
            }
        }
        .padding()
    }
}

#Preview {
    HTMLPreview(content: """
    <div class="container">
        <h1>Hello</h1>
        <p>This is a HTML preview.</p>
    </div>
    """)
    .frame(width: 400, height: 300)
}
