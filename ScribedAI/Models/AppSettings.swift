import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode = false
    @Published var isHighQualityAudio = true
    @Published var selectedLanguage = "English"
    @Published var autoPunctuation = true
    
    let availableLanguages = ["English", "Spanish", "French", "German", "Italian"]
    
    // App Info
    let version = "1.0.0"
    let privacyPolicyURL = URL(string: "https://example.com/privacy")!
} 