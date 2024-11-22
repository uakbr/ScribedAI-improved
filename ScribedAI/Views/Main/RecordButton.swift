import SwiftUI

struct RecordButton: View {
    @State private var isRecording = false
    
    var body: some View {
        Button(action: {
            isRecording.toggle()
        }) {
            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(isRecording ? .red : .blue)
                .symbolEffect(.pulse)
        }
        .buttonStyle(.borderless)
        .contentTransition(.symbolEffect(.bounce))
    }
} 