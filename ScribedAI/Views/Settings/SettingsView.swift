import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var audioRecorder: AudioRecorder
    @State private var isChangingModel = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "waveform")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("ScribedAI")
                            .font(.headline)
                        Text("Version \(appSettings.version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            
            Section {
                Toggle("Dark Mode", isOn: $appSettings.isDarkMode)
                Toggle("High Quality Audio", isOn: $appSettings.isHighQualityAudio)
            } header: {
                Text("General")
            } footer: {
                Text("High quality audio uses more storage but may improve transcription accuracy")
            }
            
            Section {
                Picker("Language", selection: $appSettings.selectedLanguage) {
                    ForEach(appSettings.availableLanguages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                
                Picker("Model", selection: $appSettings.selectedModel) {
                    ForEach(appSettings.availableModels, id: \.self) { model in
                        HStack {
                            Text(model.capitalized)
                            Spacer()
                            modelDescription(for: model)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(model)
                    }
                }
                .onChange(of: appSettings.selectedModel) { oldValue, newValue in
                    Task {
                        isChangingModel = true
                        await audioRecorder.updateTranscriptionModel(newValue)
                        isChangingModel = false
                    }
                }
                .overlay {
                    if isChangingModel {
                        ProgressView()
                    }
                }
                
                Toggle("Auto-punctuation", isOn: $appSettings.autoPunctuation)
            } header: {
                Text("Transcription")
            } footer: {
                Text("Larger models provide better accuracy but may be slower")
            }
            
            Section {
                Link("Privacy Policy", destination: appSettings.privacyPolicyURL)
                    .foregroundColor(.blue)
            }
        }
        .navigationTitle("Settings")
        .disabled(isChangingModel)
    }
    
    private func modelDescription(for model: String) -> Text {
        switch model {
        case "tiny":
            Text("Fastest")
        case "base":
            Text("Balanced")
        case "small":
            Text("Most Accurate")
        default:
            Text("")
        }
    }
} 