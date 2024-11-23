import Foundation
import WhisperKit

class TranscriptionManager: ObservableObject {
    @Published var isLoading = false
    private var whisperKit: WhisperKit?
    private var currentModel: String

    init(model: String = "tiny") async {
        self.currentModel = model
        await setupWhisperKit()
    }

    @MainActor
    func updateModel(_ newModel: String) async {
        if currentModel != newModel {
            currentModel = newModel
            await setupWhisperKit()
        }
    }

    @MainActor
    private func setupWhisperKit() async {
        do {
            whisperKit = try await WhisperKit(model: currentModel)
        } catch {
            print("Failed to initialize WhisperKit: \(error)")
        }
    }

    @MainActor
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
