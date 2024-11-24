import XCTest
@testable import ScribedAI

final class AudioRecorderTests: XCTestCase {
    func testStartAndStopRecording() {
        let audioRecorder = AudioRecorder()
        audioRecorder.startRecording()
        XCTAssertTrue(audioRecorder.isRecording)
        audioRecorder.stopRecording()
        XCTAssertFalse(audioRecorder.isRecording)
    }
} 