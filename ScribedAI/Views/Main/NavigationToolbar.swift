import SwiftUI

struct NavigationToolbar: View {
    private enum Destination: String {
        case history
        case transcripts
        case settings
        
        var icon: String {
            switch self {
            case .history: return "clock.arrow.circlepath"
            case .transcripts: return "doc.text"
            case .settings: return "gear"
            }
        }
        
        var title: String {
            rawValue.capitalized
        }
    }
    
    var body: some View {
        HStack(spacing: 40) {
            ForEach([Destination.history, .transcripts, .settings], id: \.self) { destination in
                NavigationLink(value: destination.rawValue) {
                    ToolbarButton(imageName: destination.icon, title: destination.title)
                }
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