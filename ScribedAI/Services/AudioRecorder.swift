import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var recordings: [Recording] = []
    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?
    private let transcriptionManager = TranscriptionManager()
    
    override init() {
        super.init()
        setupAudioSession()
        loadRecordings()
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
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        guard let url = currentRecordingURL else { return }
        
        Task {
            do {
                isTranscribing = true
                let text = try await transcriptionManager.transcribeAudio(url: url)
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
                }
            } catch {
                print("Transcription failed: \(error.localizedDescription)")
                isTranscribing = false
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
} 