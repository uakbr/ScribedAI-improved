import SwiftUI

struct NavigationToolbar: View {
    var body: some View {
        HStack(spacing: 40) {
            NavigationLink(value: "history") {
                ToolbarButton(imageName: "clock.arrow.circlepath", title: "History")
            }
            
            NavigationLink(value: "transcripts") {
                ToolbarButton(imageName: "doc.text", title: "Transcripts")
            }
            
            NavigationLink(value: "settings") {
                ToolbarButton(imageName: "gear", title: "Settings")
            }
        }
        .foregroundColor(.blue)
    }
}

struct ToolbarButton: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 24))
            Text(title)
                .font(.caption)
        }
    }
} 