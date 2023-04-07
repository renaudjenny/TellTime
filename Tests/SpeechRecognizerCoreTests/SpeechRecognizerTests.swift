import ComposableArchitecture
import SpeechRecognizerCore
import XCTest
import Speech

@MainActor
class SpeechRecognitionCoreTests: XCTestCase {
    func testStartRecordingFirstTimeAsksForAuthorization() async {
        let requestAuthorizationExpectation = expectation(description: "Request authorization")
        let startRecordingExpectation = expectation(description: "Start recording")

        let store = TestStore(initialState: SpeechRecognizer.State(), reducer: SpeechRecognizer()) { dependencies in
            dependencies.speechRecognizer.requestAuthorization = { requestAuthorizationExpectation.fulfill() }
            dependencies.speechRecognizer.authorizationStatus = { AsyncStream { continuation in
                continuation.yield(.authorized)
            } }
            dependencies.speechRecognizer.startRecording = { startRecordingExpectation.fulfill() }
        }

        await store.send(.buttonTapped)
        await store.receive(.setAuthorizationStatus(.authorized)) {
            $0.authorizationStatus = .authorized
        }

        wait(for: [requestAuthorizationExpectation, startRecordingExpectation], timeout: 0.1)
    }
}
