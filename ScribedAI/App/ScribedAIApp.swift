import SwiftUI

@main
struct ScribedAIApp: App {
    @StateObject private var appSettings = AppSettings()
    @StateObject private var audioRecorder = AudioRecorder()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environmentObject(audioRecorder)
        }
    }
} 