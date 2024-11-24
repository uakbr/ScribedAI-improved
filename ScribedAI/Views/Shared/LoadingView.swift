import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading, please wait...")
                .foregroundColor(.secondary)
        }
        .padding()
    }
} 