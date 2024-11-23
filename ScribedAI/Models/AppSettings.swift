import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode = false
    @Published var isHighQualityAudio = true
    @Published var selectedLanguage = "English"
    @Published var autoPunctuation = true
    @Published var selectedModel = "tiny"
    
    let availableLanguages = ["English", "Spanish", "French", "German", "Italian"]
    let availableModels = ["tiny", "base", "small"]
    
    // App Info
    let version = "1.0.0"
    let privacyPolicyURL = URL(string: "https://example.com/privacy")!
} 