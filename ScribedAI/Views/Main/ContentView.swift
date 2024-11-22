import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HeaderView()
                
                Spacer()
                
                RecordButton()
                    .environmentObject(audioRecorder)
                
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
                        .environmentObject(audioRecorder)
                case "transcripts":
                    TranscriptsView(audioRecorder: audioRecorder)
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