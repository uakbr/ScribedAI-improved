import SwiftUI

struct RecordButton: View {
    @EnvironmentObject private var audioRecorder: AudioRecorder
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                withAnimation {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(audioRecorder.isRecording ? .red.opacity(0.1) : .blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(audioRecorder.isRecording ? .red : .blue)
                        .symbolEffect(.bounce, options: .repeat(1), isActive: audioRecorder.isRecording)
                }
            }
            .buttonStyle(.borderless)
            .disabled(audioRecorder.isTranscribing)
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1), radius: 10)
            
            if !audioRecorder.recordingFeedback.isEmpty {
                Text(audioRecorder.recordingFeedback)
                    .foregroundColor(.secondary)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    }
            }
            
            if audioRecorder.isTranscribing {
                VStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Transcribing...")
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: audioRecorder.isRecording)
    }
} 