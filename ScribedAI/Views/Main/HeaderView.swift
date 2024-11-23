import SwiftUI

struct HeaderView: View {
    @State private var animateIcon = false

    var body: some View {
        VStack {
            Image(systemName: "waveform")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(animateIcon ? 0 : 360))
                .animation(.easeOut(duration: 1), value: animateIcon)
                .onAppear {
                    animateIcon = true
                }

            Text("ScribedAI")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Voice to Text Transcription")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
} 