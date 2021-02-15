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
    var isAboutPresented = false
    var tellTime: String?
}

enum AppAction: Equatable {
    case setDate(Date)
    case setRandomDate
    case configuration(ConfigurationAction)
    case tts(TTSAction)
    case speechRecognition(SpeechRecognitionAction)
    case appStarted
    case presentAbout
    case hideAbout
}

struct AppEnvironment {
    var currentDate: () -> Date
    var randomDate: (Calendar) -> Date
    var ttsEngine: TTSEngine
    var calendar: Calendar
    var tellTime: (Date, Calendar) -> String
    var speechRecognitionEngine: SpeechRecognitionEngine
    var recognizeTime: (String, Calendar) -> Date?
    var mainQueue: AnySchedulerOf<DispatchQueue>
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
            tellTime: $0.tellTime,
            mainQueue: $0.mainQueue
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
        case let .setDate(date):
            state.date = date
            state.tellTime = environment.tellTime(date, environment.calendar)
            return .none
        case .setRandomDate:
            let randomDate = environment.randomDate(environment.calendar)
            return Effect(value: .setDate(randomDate))
        case .appStarted:
            if state.tellTime == nil {
                return Effect(value: .setDate(state.date))
            }
            return .none
        case .presentAbout:
            state.isAboutPresented = true
            return .none
        case .hideAbout:
            state.isAboutPresented = false
            return .none
        case let .speechRecognition(.setRecognizedDate(date)):
            return Effect(value: .setDate(date))
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
        let state: AppState = .preview(modifyState: modifyState)
        let environment: AppEnvironment = .preview(modifyEnvironment: modifyEnvironment)

        return Self(initialState: state, reducer: appReducer, environment: environment)
    }

    static var preview: Self { preview() }
}

extension AppState {
    static func preview(
        modifyState: (inout AppState) -> Void = { _ in }
    ) -> Self {
        var state = AppState()
        modifyState(&state)
        return state
    }

    static var preview: Self { .preview() }
}

extension AppEnvironment {
    static func preview(
        modifyEnvironment: (inout AppEnvironment) -> Void = { _ in }
    ) -> Self {
        var environment = AppEnvironment(
            currentDate: { Date() },
            randomDate: generateRandomDate,
            ttsEngine: MockedTTSEngine(),
            calendar: Calendar.autoupdatingCurrent,
            tellTime: mockedTellTime,
            speechRecognitionEngine: MockedSpeechRecognitionEngine(),
            recognizeTime: { _, _ in nil },
            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
        modifyEnvironment(&environment)
        return environment
    }

    static var preview: Self { .preview() }
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
    func requestAuthorization() { }
    func startRecording() throws { }
    func stopRecording() { }
}

func mockedTellTime(date: Date, calendar: Calendar) -> String { "12:34" }
#endif
