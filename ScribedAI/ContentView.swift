//
//  ContentView.swift
//  ScribedAI
//
//  Created by u on 11/22/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "waveform")
                    .imageScale(.large)
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, options: .repeating)
                
                Text("ScribedAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Voice to Text Transcription")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    // Add recording action here
                }) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                        .symbolEffect(.pulse)
                }
                .buttonStyle(.borderless)
                .contentTransition(.symbolEffect(.bounce))
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 40) {
                        NavigationLink(value: "history") {
                            VStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 24))
                                Text("History")
                                    .font(.caption)
                            }
                        }
                        
                        NavigationLink(value: "transcripts") {
                            VStack {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 24))
                                Text("Transcripts")
                                    .font(.caption)
                            }
                        }
                        
                        NavigationLink(value: "settings") {
                            VStack {
                                Image(systemName: "gear")
                                    .font(.system(size: 24))
                                Text("Settings")
                                    .font(.caption)
                            }
                        }
                    }
                    .foregroundColor(.blue)
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

// MARK: - Navigation Views
struct HistoryView: View {
    var body: some View {
        List {
            // History items will go here
            Text("Recent Recordings")
                .font(.headline)
        }
        .navigationTitle("History")
    }
}

struct TranscriptsView: View {
    var body: some View {
        List {
            // Transcripts will go here
            Text("Your Transcripts")
                .font(.headline)
        }
        .navigationTitle("Transcripts")
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("General") {
                Toggle("Dark Mode", isOn: .constant(false))
                Toggle("High Quality Audio", isOn: .constant(true))
            }
            
            Section("Transcription") {
                Picker("Language", selection: .constant("English")) {
                    Text("English").tag("English")
                    Text("Spanish").tag("Spanish")
                    Text("French").tag("French")
                }
                
                Toggle("Auto-punctuation", isOn: .constant(true))
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    ContentView()
}
