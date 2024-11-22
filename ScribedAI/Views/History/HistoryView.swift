import SwiftUI

struct HistoryView: View {
    @State private var recordings: [Recording] = []
    
    var body: some View {
        List {
            ForEach(recordings) { recording in
                RecordingRow(recording: recording)
            }
            .onDelete(perform: deleteRecordings)
        }
        .navigationTitle("History")
        .toolbar {
            EditButton()
        }
    }
    
    private func deleteRecordings(at offsets: IndexSet) {
        recordings.remove(atOffsets: offsets)
    }
}

struct Recording: Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let text: String
}

struct RecordingRow: View {
    let recording: Recording
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.date, style: .date)
                .font(.headline)
            Text(recording.text)
                .lineLimit(2)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 