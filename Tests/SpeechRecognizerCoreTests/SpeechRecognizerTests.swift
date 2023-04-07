import ComposableArchitecture
import SpeechRecognizerCore
import XCTest
import Speech

@MainActor
class SpeechRecognitionCoreTests: XCTestCase {
    func testStartRecordingFirstTimeAsksForAuthorization() async {
        let requestAuthorizationExpectation = expectation(description: "Request authorization")
        let startRecordingExpectation = expectation(description: "Start recording")

        var recordingStarted: () -> Void = {}
        let store = TestStore(initialState: SpeechRecognizer.State(), reducer: SpeechRecognizer()) { dependencies in
            dependencies.speechRecognizer.requestAuthorization = { requestAuthorizationExpectation.fulfill() }
            dependencies.speechRecognizer.authorizationStatus = { AsyncStream { continuation in
                continuation.yield(.authorized)
            } }
            dependencies.speechRecognizer.startRecording = { startRecordingExpectation.fulfill() }
            dependencies.speechRecognizer.recognitionStatus = { AsyncStream { continuation in
                continuation.yield(.recording)
            } }
            dependencies.speechRecognizer.newUtterance = { AsyncStream { continuation in
                recordingStarted = {
                    continuation.yield("Test")
                }
            } }
        }

        await store.send(.buttonTapped)
        await store.receive(.setAuthorizationStatus(.authorized)) {
            $0.authorizationStatus = .authorized
        }
        await store.receive(.setStatus(.recording)) {
            $0.status = .recording
        }
        recordingStarted()
        await store.receive(.setUtterance("Test")) {
            $0.utterance = "Test"
        }

        await fulfillment(of: [requestAuthorizationExpectation, startRecordingExpectation])
        await store.send(.cancel)
    }
}
