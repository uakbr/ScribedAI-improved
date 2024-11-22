import SwiftUI

struct RecordButton: View {
    @StateObject private var audioRecorder = AudioRecorder()
    
    var body: some View {
        Button(action: {
            if audioRecorder.isRecording {
                audioRecorder.stopRecording()
            } else {
                audioRecorder.startRecording()
            }
        }) {
            Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(audioRecorder.isRecording ? .red : .blue)
                .symbolEffect(.pulse, isActive: audioRecorder.isRecording)
        }
        .buttonStyle(.borderless)
        .contentTransition(.identity)
        .disabled(audioRecorder.isTranscribing)
        .overlay {
            if audioRecorder.isTranscribing {
                ProgressView()
                    .controlSize(.large)
            }
        }
    }
} 