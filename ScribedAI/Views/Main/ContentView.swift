import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HeaderView()
                
                Spacer()
                
                RecordButton()
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationToolbar()
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "history":
                    HistoryView()
                case "transcripts":
                    TranscriptsView()
                case "settings":
                    SettingsView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
} 