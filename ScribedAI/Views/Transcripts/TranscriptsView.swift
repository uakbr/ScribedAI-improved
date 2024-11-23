import SwiftUI
import Combine

struct TranscriptsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var searchText = ""
    @State private var selectedTranscript: Recording?
    @State private var showErrorAlert = false
    
    var body: some View {
        Group {
            if audioRecorder.recordings.isEmpty {
                ContentUnavailableView(
                    "No Transcripts",
                    systemImage: "doc.text",
                    description: Text("Your transcribed recordings will appear here")
                )
            } else {
                List {
                    ForEach(filteredTranscripts) { recording in
                        TranscriptRow(transcript: recording, audioRecorder: audioRecorder)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTranscript = recording
                            }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            audioRecorder.deleteRecordings(at: indexSet)
                        }
                    }
                }
            }
        }
        .navigationTitle("Transcripts")
        .searchable(text: $searchText, prompt: "Search transcripts")
        .toolbar {
            if !audioRecorder.recordings.isEmpty {
                EditButton()
            }
        }
        .sheet(item: $selectedTranscript) { transcript in
            TranscriptDetailView(transcript: transcript, audioRecorder: audioRecorder)
        }
        .onReceive(audioRecorder.transcriptionManager?.$errorMessage ?? Just(nil).eraseToAnyPublisher()) { errorMessage in
            if errorMessage != nil {
                showErrorAlert = true
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(audioRecorder.transcriptionManager?.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK")) {
                    audioRecorder.transcriptionManager?.errorMessage = nil
                }
            )
        }
    }
    
    private var filteredTranscripts: [Recording] {
        if searchText.isEmpty {
            return audioRecorder.recordings
        }
        return audioRecorder.recordings.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }
}

struct TranscriptRow: View {
    let transcript: Recording
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(transcript.date, style: .date)
                    .font(.headline)
                Spacer()
                Button(action: {
                    if let url = audioRecorder.getAudioURL(for: transcript) {
                        isPlaying.toggle()
                        audioRecorder.playAudio(url: url)
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            
            Text(transcript.text)
                .lineLimit(3)
                .font(.subheadline)
            
            HStack {
                Label(String(format: "%.1f sec", transcript.duration), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(transcript.language, systemImage: "globe")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct TranscriptDetailView: View {
    let transcript: Recording
    @ObservedObject var audioRecorder: AudioRecorder
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(transcript.date, style: .date)
                                .font(.headline)
                            Text(transcript.date, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let url = audioRecorder.getAudioURL(for: transcript) {
                                isPlaying.toggle()
                                audioRecorder.playAudio(url: url)
                            }
                        }) {
                            Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Divider()
                    
                    Text(transcript.text)
                        .font(.body)
                    
                    HStack {
                        Label(String(format: "%.1f seconds", transcript.duration), systemImage: "clock")
                        Spacer()
                        Label(transcript.language, systemImage: "globe")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Transcript Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
} 