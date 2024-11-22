import SwiftUI

struct HistoryView: View {
    @State private var recordings: [Recording] = []
    
    var body: some View {
        List {
            ForEach(recordings) { recording in
                RecordingRow(recording: recording)
            }
        }
        .navigationTitle("History")
    }
}

struct RecordingRow: View {
    let recording: Recording
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recording.date, style: .date)
            Text(recording.text)
                .lineLimit(2)
        }
    }
} 