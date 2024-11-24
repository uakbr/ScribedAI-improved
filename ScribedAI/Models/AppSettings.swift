import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            userDefaults.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    @Published var isHighQualityAudio = true
    @Published var selectedLanguage = "English"
    @Published var autoPunctuation = true
    @Published var selectedModel = "tiny"
    
    let availableLanguages = ["English", "Spanish", "French", "German", "Italian", "Japanese", "Chinese", "Arabic", "Portuguese", "Russian", "Korean"]
    let availableModels = ["tiny", "base", "small"]
    
    // App Info
    let version = "1.0.0"
    let privacyPolicyURL = URL(string: "https://yourdomain.com/privacy-policy")!

    private let userDefaults = UserDefaults.standard

    init() {
        // Initialize isDarkMode from UserDefaults
        self.isDarkMode = userDefaults.bool(forKey: "isDarkMode")
        // ... initialize other settings ...
    }
} 