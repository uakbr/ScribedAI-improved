import SwiftUI

struct TranscriptsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(filteredTranscripts) { recording in
                TranscriptRow(transcript: recording)
            }
            .onDelete { indexSet in
                withAnimation {
                    audioRecorder.deleteRecordings(at: indexSet)
                }
            }
        }
        .navigationTitle("Transcripts")
        .searchable(text: $searchText)
        .toolbar {
            EditButton()
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(transcript.date, style: .date)
                .font(.headline)
            Text(transcript.text)
                .lineLimit(3)
                .font(.subheadline)
            Text(transcript.language)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 