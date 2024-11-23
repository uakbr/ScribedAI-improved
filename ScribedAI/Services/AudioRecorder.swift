import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var recordings: [Recording] = []
    @Published var recordingFeedback = ""
    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?
    private var transcriptionManager: TranscriptionManager?
    
    override init() {
        super.init()
        setupAudioSession()
        loadRecordings()
        
        // Initialize TranscriptionManager asynchronously
        Task {
            transcriptionManager = await TranscriptionManager(model: "tiny")
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
        let filename = "\(Date().ISO8601Format()).m4a"
        currentRecordingURL = getDocumentsDirectory().appendingPathComponent(filename)
        
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
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingFeedback = "Processing..."
        
        guard let url = currentRecordingURL else { return }
        
        Task {
            do {
                isTranscribing = true
                guard let manager = transcriptionManager else {
                    throw NSError(domain: "AudioRecorder", code: 1, userInfo: [NSLocalizedDescriptionKey: "TranscriptionManager not initialized"])
                }
                let text = try await manager.transcribeAudio(url: url)
                let recording = Recording(
                    id: UUID(),
                    date: Date(),
                    url: url,
                    text: text,
                    language: "en",
                    duration: audioRecorder?.currentTime ?? 0
                )
                
                await MainActor.run {
                    recordings.append(recording)
                    saveRecordings()
                    isTranscribing = false
                    recordingFeedback = "Recording saved!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.recordingFeedback = ""
                    }
                }
            } catch {
                print("Transcription failed: \(error.localizedDescription)")
                await MainActor.run {
                    recordingFeedback = "Transcription failed"
                    isTranscribing = false
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveRecordings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(recordings) {
            UserDefaults.standard.set(encoded, forKey: "recordings")
        }
    }
    
    private func loadRecordings() {
        if let data = UserDefaults.standard.data(forKey: "recordings"),
           let decoded = try? JSONDecoder().decode([Recording].self, from: data) {
            recordings = decoded
        }
    }
    
    func deleteRecordings(at offsets: IndexSet) {
        recordings.remove(atOffsets: offsets)
        saveRecordings()
    }
    
    func getAudioURL(for recording: Recording) -> URL? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: recording.url.path) {
            return recording.url
        }
        return nil
    }
    
    func playAudio(url: URL) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
} 