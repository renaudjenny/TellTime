import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import SwiftTTSCombine
import Speech
import AVFoundation

class TelltimeTests: XCTestCase {
    func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
        let fakeEnvironment: AppEnvironment = .fake(currentDate: fakeCurrentDate)

        let store = Store<AppState, AppAction, AppEnvironment>(
            initialState: AppState(date: fakeCurrentDate),
            reducer: appReducer,
            environment: fakeEnvironment
        )

        let tellTime = EnvironmentValues().tellTime
        XCTAssertEqual(tellTime(store.state.date, .test), "It's one eleven AM.")
    }

    func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4360)

        let store = testStore
        store.send(.changeDate(fakeCurrentDate))

        let tellTime = EnvironmentValues().tellTime
        XCTAssertEqual(tellTime(store.state.date, .test), "It's one twelve AM.")
    }
}

func testStore(
    modifyState: (inout AppState) -> Void = { _ in },
    environment: AppEnvironment = .fake
) -> Store<AppState, AppAction, AppEnvironment> {
    var state = AppState(date: environment.currentDate())
    _ = modifyState(&state)
    return .init(initialState: state, reducer: appReducer, environment: environment)
}

var testStore: Store<AppState, AppAction, AppEnvironment> { testStore() }

extension AppEnvironment {
    static var fake: Self {
        fake(currentDate: Date(hour: 10, minute: 10, calendar: .test))
    }

    static func fake(currentDate: Date) -> Self {
        Self(
            currentDate: { currentDate },
            tts: .fake,
            speechRecognition: .fake
        )
    }
}

extension TTSEnvironment {
    static var fake: Self {
        TTSEnvironment(
            engine: MockedTTSEngine(),
            calendar: .test,
            tellTime: { _, _ in "12:34" }
        )
    }

    private final class MockedTTSEngine: TTSEngine {
        var rateRatio: Float = 1.0
        var voice: AVSpeechSynthesisVoice?
        func speak(string: String) { }
        var isSpeakingPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
        var speakingProgressPublisher: AnyPublisher<Double, Never> { Just(0.0).eraseToAnyPublisher() }
    }
}

extension SpeechRecognitionEnvironment {
    static var fake: Self {
        SpeechRecognitionEnvironment(
            engine: MockedSpeechRecognitionEngine(),
            recognizeTime: { _, _ in nil },
            calendar: .test
        )
    }

    private final class MockedSpeechRecognitionEngine: SpeechRecognitionEngine {
        var authorizationStatusPublisher: AnyPublisher<SFSpeechRecognizerAuthorizationStatus?, Never> {
            Just(.notDetermined).eraseToAnyPublisher()
        }
        var recognizedUtterancePublisher: AnyPublisher<String?, Never> { Just(nil).eraseToAnyPublisher() }
        var recognitionStatusPublisher: AnyPublisher<SpeechRecognitionStatus, Never> {
            Just(.notStarted).eraseToAnyPublisher()
        }
        var isRecognitionAvailablePublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
        var newUtterancePublisher: AnyPublisher<String, Never> { Just("").eraseToAnyPublisher() }
        func requestAuthorization(completion: @escaping () -> Void) { completion() }
        func startRecording() throws { }
        func stopRecording() { }
    }
}
