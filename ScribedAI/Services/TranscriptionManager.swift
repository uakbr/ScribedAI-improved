import Foundation
import WhisperKit

class TranscriptionManager: ObservableObject {
    @Published var isLoading = false
    private var whisperKit: WhisperKit?
    private var currentModel: String
    @Published var errorMessage: String?

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
            self.errorMessage = "Failed to initialize the transcription model: \(error.localizedDescription)"
            print("Failed to initialize WhisperKit: \(error.localizedDescription)")
        }
    }

    func transcribeAudio(url: URL) async throws -> String {
        guard let whisperKit = whisperKit else {
            let errorMsg = "Transcription model is not initialized."
            await MainActor.run {
                self.errorMessage = errorMsg
            }
            throw NSError(domain: "TranscriptionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }

        // Update isLoading on main thread
        await MainActor.run {
            self.isLoading = true
        }
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        do {
            let results = try await whisperKit.transcribe(audioPath: url.path)
            return results.first?.text ?? ""
        } catch {
            await MainActor.run {
                self.errorMessage = "Transcription failed: \(error.localizedDescription)"
            }
            throw error
        }
    }
}
