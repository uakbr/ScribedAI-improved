import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var recordings: [Recording] = []
    @Published var recordingFeedback = ""
    @Published var errorMessage: String?
    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?
    private var transcriptionManager: TranscriptionManager?
    private var audioPlayer: AVAudioPlayer?
    private let recordingsDirectory: URL
    private let recordingsMetadataURL: URL
    
    override init() {
        // Initialize directories before calling super.init()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.recordingsDirectory = documentsDirectory.appendingPathComponent("Recordings")
        self.recordingsMetadataURL = recordingsDirectory.appendingPathComponent("recordingsMetadata.json")

        super.init()
        setupAudioSession()
        createRecordingsDirectory()
        loadRecordings()
        
        // Initialize TranscriptionManager asynchronously
        Task {
            transcriptionManager = await TranscriptionManager(model: "tiny")
        }
    }
    
    private func createRecordingsDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: recordingsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Failed to create recordings directory: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateTranscriptionModel(_ model: String) async {
        isTranscribing = true
        await transcriptionManager?.updateModel(model)
        isTranscribing = false
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        let filename = "\(UUID().uuidString).m4a"
        currentRecordingURL = recordingsDirectory.appendingPathComponent(filename)
        
        guard let url = currentRecordingURL else { return }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingFeedback = "Recording..."
        } catch {
            recordingFeedback = "Failed to start recording"
            DispatchQueue.main.async {
                self.errorMessage = "Unable to start recording: \(error.localizedDescription)"
            }
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()

        // Ensure these updates are on the main thread
        DispatchQueue.main.async {
            self.isRecording = false
            self.recordingFeedback = "Processing..."
        }
        
        guard let url = currentRecordingURL else { return }

        Task.detached {
            do {
                // Notify UI that transcription is starting
                await MainActor.run {
                    self.isTranscribing = true
                }

                guard let manager = self.transcriptionManager else {
                    throw NSError(domain: "AudioRecorder", code: 1, userInfo: [NSLocalizedDescriptionKey: "TranscriptionManager not initialized"])
                }

                let text = try await manager.transcribeAudio(url: url)
                let recording = Recording(
                    id: UUID(),
                    date: Date(),
                    url: url,
                    text: text,
                    language: "en",
                    duration: self.audioRecorder?.currentTime ?? 0
                )

                // Update recordings on the main thread
                await MainActor.run {
                    self.recordings.append(recording)
                    self.saveRecordings()
                    self.isTranscribing = false
                    self.recordingFeedback = "Recording saved!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.recordingFeedback = ""
                    }
                }
            } catch {
                print("Transcription failed: \(error.localizedDescription)")
                await MainActor.run {
                    self.recordingFeedback = "Transcription failed"
                    self.isTranscribing = false
                    self.errorMessage = "Transcription failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return recordingsDirectory
    }
    
    private func saveRecordings() {
        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: recordingsMetadataURL)
        } catch {
            print("Failed to save recordings metadata: \(error.localizedDescription)")
        }
    }
    
    private func loadRecordings() {
        do {
            let data = try Data(contentsOf: recordingsMetadataURL)
            let decodedRecordings = try JSONDecoder().decode([Recording].self, from: data)
            recordings = decodedRecordings
        } catch {
            print("Failed to load recordings metadata: \(error.localizedDescription)")
            recordings = []
        }
    }
    
    func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            do {
                try FileManager.default.removeItem(at: recording.url)
            } catch {
                print("Failed to delete recording file: \(error.localizedDescription)")
            }
        }
        recordings.remove(atOffsets: offsets)
        saveRecordings()
    }
    
    func getAudioURL(for recording: Recording) -> URL? {
        let fileManager = FileManager.default
        let fileURL = recordingsDirectory.appendingPathComponent(recording.url.lastPathComponent)
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        return nil
    }
    
    func playAudio(url: URL) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error playing audio: \(error.localizedDescription)"
            }
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
} 