import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import ComposableArchitecture
import SwiftSpeechCombine
import Speech

class SpeechRecognitionCoreTests: XCTestCase {
    let scheduler = DispatchQueue.test

    // swiftlint:disable function_body_length
    func testButtonTappedWhenNotAuthorizedYetAndAuthorizeRecord() {
        let engineRequestAuthorizationCallExpectation = self.expectation(
            description: "Engine Request Authorization Called"
        )
        let engineStartRecordingCallExpectation = self.expectation(
            description: "Engine Start Recording Called"
        )
        let engineStopRecordingCallExpectation = self.expectation(
            description: "Engine Stop Recording Called"
        )

        let engine = MockedSpeechRecognitionEngine()
        engine.requestAuthorizationCall = engineRequestAuthorizationCallExpectation.fulfill
        engine.startRecordingCall = engineStartRecordingCallExpectation.fulfill
        engine.stopRecordingCall = engineStopRecordingCallExpectation.fulfill

        let utterance = "A time easy to recognize 9:45 am"
        // Epoch + 35100 = 1970-01-01T09:45:00 GMT
        let recognizedDate = Date(timeIntervalSince1970: 35100)
        let tellTime = "It's quarter to nine am"

        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .test {
                $0.speechRecognitionEngine = engine
                $0.mainQueue = scheduler.eraseToAnyScheduler()
                $0.recognizeTime = { string, _ in
                    guard string == utterance
                    else { return nil }

                    // Epoch + 35100 = 1970-01-01T09:45:00 GMT
                    return Date(timeIntervalSince1970: 35100)
                }
                $0.tellTime = { date, _ in
                    guard date == recognizedDate
                    else { return "ERROR" }
                    return tellTime
                }
            }
        )

        store.send(.speechRecognition(.buttonTapped))
        store.receive(.speechRecognition(.startRecording))
        store.receive(.speechRecognition(.requestAuthorization))
        engine.authorizationStatus.send(.authorized)
        scheduler.advance()
        store.receive(.speechRecognition(.setAuthorizationStatus(.authorized))) {
            $0.speechRecognition.authorizationStatus = .authorized
        }
        store.receive(.speechRecognition(.startRecording))
        engine.recognitionStatus.send(.recording)
        scheduler.advance()
        store.receive(.speechRecognition(.setStatus(.recording))) {
            $0.speechRecognition.status = .recording
        }
        engine.newUtterance.send(utterance)
        scheduler.advance()
        store.receive(.speechRecognition(.setUtterance(utterance))) {
            $0.speechRecognition.utterance = utterance
        }
        scheduler.advance(by: .seconds(1))
        store.receive(.speechRecognition(.setRecognizedDate(recognizedDate)))
        store.receive(.speechRecognition(.stopRecording))
        store.receive(.setDate(recognizedDate)) {
            $0.date = recognizedDate
            $0.tellTime = tellTime
        }
        engine.recognitionStatus.send(.stopped)
        scheduler.advance()
        store.receive(.speechRecognition(.setStatus(.stopped))) {
            $0.speechRecognition.status = .stopped
            $0.speechRecognition.utterance = nil
        }

        self.wait(
            for: [
                engineRequestAuthorizationCallExpectation,
                engineStartRecordingCallExpectation,
                engineStopRecordingCallExpectation,
            ],
            timeout: 0.1
        )
    }
}

private final class MockedSpeechRecognitionEngine: SpeechRecognitionEngine {
    var authorizationStatusPublisher: AnyPublisher<SFSpeechRecognizerAuthorizationStatus?, Never> {
        authorizationStatus.eraseToAnyPublisher()
    }
    var recognizedUtterancePublisher: AnyPublisher<String?, Never> {
        recognizedUtterance.eraseToAnyPublisher()
    }
    var recognitionStatusPublisher: AnyPublisher<SpeechRecognitionStatus, Never> {
        recognitionStatus.eraseToAnyPublisher()
    }
    var isRecognitionAvailablePublisher: AnyPublisher<Bool, Never> {
        isRecognitionAvailable.eraseToAnyPublisher()
    }
    var newUtterancePublisher: AnyPublisher<String, Never> {
        newUtterance.eraseToAnyPublisher()
    }

    func requestAuthorization() {
        requestAuthorizationCall()
    }

    func startRecording() throws {
        startRecordingCall()
    }

    func stopRecording() {
        stopRecordingCall()
    }

    var authorizationStatus = PassthroughSubject<SFSpeechRecognizerAuthorizationStatus?, Never>()
    var recognizedUtterance = PassthroughSubject<String?, Never>()
    var recognitionStatus = PassthroughSubject<SpeechRecognitionStatus, Never>()
    var isRecognitionAvailable = PassthroughSubject<Bool, Never>()
    var newUtterance = PassthroughSubject<String, Never>()

    var requestAuthorizationCall: () -> Void = { }
    var startRecordingCall: () -> Void = { }
    var stopRecordingCall: () -> Void = { }
}
