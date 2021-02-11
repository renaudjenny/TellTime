import SwiftUI
import Combine
import SwiftTTSCombine
import Speech
import AVFoundation
import ComposableArchitecture

struct AppState: Equatable {
    var date: Date
    var configuration = ConfigurationState()
    var tts = TTSState()
    var speechRecognition = SpeechRecognitionState()
}

enum AppAction {
    case changeDate(Date)
    case configuration(ConfigurationAction)
    case tts(TTSAction)
    case speechRecognition(SpeechRecognitionAction)
}

struct AppEnvironment {
    let currentDate: () -> Date
    let tts: TTSEnvironment
    let speechRecognition: SpeechRecognitionEnvironment
}

func appReducer(
    state: inout AppState,
    action: AppAction,
    environment: AppEnvironment
) -> AnyPublisher<AppAction, Never>? {
    switch action {
    case let .changeDate(date):
        state.date = date
    case let .configuration(action):
        configurationReducer(state: &state.configuration, action: action)
    case let .tts(action):
        guard let effect = ttsReducer(state: &state.tts, action: action, environment: environment.tts) else {
            return nil
        }
        return effect
            .map { AppAction.tts($0) }
            .eraseToAnyPublisher()
    case let .speechRecognition(action):
        guard let effect = speechRecognitionReducer(
            state: &state.speechRecognition,
            action: action,
            environment: environment.speechRecognition
        )
        else { return nil }

        return effect
            .map { AppAction.speechRecognition($0) }
            .eraseToAnyPublisher()
    }
    return nil
}

#if DEBUG
extension Store where State == AppState, Action == AppAction {
    static func preview(
        modifyState: (inout AppState) -> Void = { _ in },
        modifyEnvironment: (inout AppEnvironment) -> Void = { _ in }
    ) -> Self {
        var state = AppState(date: Date())
        modifyState(&state)

        let calendar = Calendar.autoupdatingCurrent
        var environment = AppEnvironment(
            currentDate: { Date() },
            tts: TTSEnvironment(engine: MockedTTSEngine(), calendar: calendar, tellTime: { _, _ in "" }),
            speechRecognition: SpeechRecognitionEnvironment(engine: MockedSpeechRecognitionEngine(), recognizeTime: { _, _ in nil }, calendar: calendar)
        )

        return Store(initialState: state, reducer: appReducer, environment: environment)
    }

    static var preview: Self { preview() }
}

private final class MockedTTSEngine: TTSEngine {
    var rateRatio: Float = 1.0
    var voice: AVSpeechSynthesisVoice?
    func speak(string: String) { }
    var isSpeakingPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
    var speakingProgressPublisher: AnyPublisher<Double, Never> { Just(0.0).eraseToAnyPublisher() }
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

func mockedTellTime(date: Date, calendar: Calendar) -> String { "12:34" }
#endif
