import SwiftUI
import Combine
import SwiftTTSCombine
import Speech
import AVFoundation
import ComposableArchitecture

struct AppState: Equatable {
    var date: Date = Date()
    var configuration = ConfigurationState()
    var tts = TTSState()
    var speechRecognition = SpeechRecognitionState()
}

enum AppAction: Equatable {
    case changeDate(Date)
    case configuration(ConfigurationAction)
    case tts(TTSAction)
    case speechRecognition(SpeechRecognitionAction)
}

struct AppEnvironment {
    var currentDate: () -> Date
    var randomDate: (Calendar) -> Date
    var ttsEngine: TTSEngine
    var calendar: Calendar
    var tellTime: (Date, Calendar) -> String
    var speechRecognitionEngine: SpeechRecognitionEngine
    var recognizeTime: (String, Calendar) -> Date?
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    configurationReducer.pullback(
        state: \.configuration,
        action: /AppAction.configuration,
        environment: { _ in ConfigurationEnvironment() }
    ),
    ttsReducer.pullback(
        state: \.tts,
        action: /AppAction.tts,
        environment: { TTSEnvironment(
            engine: $0.ttsEngine,
            calendar: $0.calendar,
            tellTime: $0.tellTime
        ) }
    ),
    speechRecognitionReducer.pullback(
        state: \.speechRecognition,
        action: /AppAction.speechRecognition,
        environment: { SpeechRecognitionEnvironment(
            engine: $0.speechRecognitionEngine,
            recognizeTime: $0.recognizeTime,
            calendar: $0.calendar
        ) }
    ),
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        switch action {
        case let .changeDate(date):
            state.date = date
            return .none
        case .configuration: return .none
        case .tts: return .none
        case .speechRecognition: return .none
        }
    }
)

#if DEBUG
extension Store where State == AppState, Action == AppAction {
    static func preview(
        modifyState: (inout AppState) -> Void = { _ in },
        modifyEnvironment: (inout AppEnvironment) -> Void = { _ in }
    ) -> Self {
        var state = AppState()
        modifyState(&state)

        let calendar = Calendar.autoupdatingCurrent
        var environment = AppEnvironment(
            currentDate: { Date() },
            randomDate: randomDate,
            ttsEngine: MockedTTSEngine(),
            calendar: calendar,
            tellTime: { _, _ in "" },
            speechRecognitionEngine: MockedSpeechRecognitionEngine(),
            recognizeTime: { _, _ in nil }
        )
        modifyEnvironment(&environment)

        return Self(initialState: state, reducer: appReducer, environment: environment)
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
