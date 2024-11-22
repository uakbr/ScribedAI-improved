import Foundation
import WhisperKit

class TranscriptionManager: ObservableObject {
    @Published var isLoading = false
    private var whisperKit: WhisperKit?

    init() {
        setupWhisperKit()
    }

    private func setupWhisperKit() {
        Task {
            do {
                // Initialize WhisperKit with the desired model name
                whisperKit = try await WhisperKit(model: "tiny")
            } catch {
                print("Failed to initialize WhisperKit: \(error)")
            }
        }
    }

    func transcribeAudio(url: URL) async throws -> String {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "TranscriptionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }

        isLoading = true
        defer { isLoading = false }

        // Transcribe the audio file and return the first result
        let results = try await whisperKit.transcribe(audioPath: url.path)
        return results.first?.text ?? ""
    }
}
