import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var audioRecorder: AudioRecorder
    
    var body: some View {
        Group {
            if audioRecorder.recordings.isEmpty {
                ContentUnavailableView(
                    "No Recordings",
                    systemImage: "waveform",
                    description: Text("Your recorded audio will appear here")
                )
            } else {
                List {
                    ForEach(audioRecorder.recordings) { recording in
                        RecordingRow(recording: recording)
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            audioRecorder.deleteRecordings(at: indexSet)
                        }
                    }
                }
                .toolbar {
                    EditButton()
                }
            }
        }
        .navigationTitle("History")
    }
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
            HStack {
                Text(String(format: "%.1f sec", recording.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(recording.language)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 