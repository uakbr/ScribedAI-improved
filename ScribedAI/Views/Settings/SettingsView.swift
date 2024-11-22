import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    
    var body: some View {
        List {
            Section("General") {
                Toggle("Dark Mode", isOn: $appSettings.isDarkMode)
                Toggle("High Quality Audio", isOn: $appSettings.isHighQualityAudio)
            }
            
            Section("Transcription") {
                Picker("Language", selection: $appSettings.selectedLanguage) {
                    ForEach(appSettings.availableLanguages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                
                Toggle("Auto-punctuation", isOn: $appSettings.autoPunctuation)
            }
            
            Section("About") {
                LabeledContent("Version", value: appSettings.version)
                Link("Privacy Policy", destination: appSettings.privacyPolicyURL)
            }
        }
        .navigationTitle("Settings")
    }
} 