import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedTab = 0
    @State private var showErrorAlert = false
    
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
                    ContentUnavailableView(
                        "Invalid Navigation",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The requested page '\(destination)' does not exist")
                    )
                }
            }
        }
        .onReceive(audioRecorder.$errorMessage.compactMap { $0 }) { errorMessage in
            showErrorAlert = true
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(audioRecorder.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK")) {
                    audioRecorder.errorMessage = nil
                }
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
        .environmentObject(AudioRecorder())
} 