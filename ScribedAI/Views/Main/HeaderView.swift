import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack {
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
        }
    }
} 