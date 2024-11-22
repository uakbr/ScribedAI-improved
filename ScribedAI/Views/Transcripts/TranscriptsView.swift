import SwiftUI

struct TranscriptsView: View {
    @State private var transcripts: [Transcript] = []
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(filteredTranscripts) { transcript in
                TranscriptRow(transcript: transcript)
            }
            .onDelete(perform: deleteTranscripts)
        }
        .navigationTitle("Transcripts")
        .searchable(text: $searchText)
        .toolbar {
            EditButton()
        }
    }
    
    private var filteredTranscripts: [Transcript] {
        if searchText.isEmpty {
            return transcripts
        }
        return transcripts.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func deleteTranscripts(at offsets: IndexSet) {
        transcripts.remove(atOffsets: offsets)
    }
}

struct Transcript: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
    let language: String
}

struct TranscriptRow: View {
    let transcript: Transcript
    
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