import SwiftUI
import Combine
import Speech
import AVFoundation
import ComposableArchitecture
import SpeechRecognizerCore
import TTSCore

struct AppState: Equatable {
    var date: Date = Date()
    var configuration = Configuration.State()
    var tts = TTS.State()
    var speechRecognizer = SpeechRecognizer.State()
    var isAboutPresented = false
    var tellTime: String?
}

enum AppAction: Equatable {
    case setDate(Date)
    case setRandomDate
    case configuration(Configuration.Action)
    case tts(TTS.Action)
    case speechRecognizer(SpeechRecognizer.Action)
    case appStarted
    case presentAbout
    case hideAbout
}

struct AppEnvironment {
    var currentDate: () -> Date
    var randomDate: (Calendar) -> Date
    var calendar: Calendar
    var tellTime: (Date, Calendar) -> String
    var recognizeTime: (String, Calendar) -> Date?
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    AnyReducer(Configuration()).pullback(state: \.configuration, action: /AppAction.configuration, environment: { $0 }),
    AnyReducer(TTS()).pullback(state: \.tts, action: /AppAction.tts, environment: { $0 }),
    AnyReducer(SpeechRecognizer()).pullback(
        state: \.speechRecognizer,
        action: /AppAction.speechRecognizer,
        environment: { $0 }
    ),
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        struct RecognizedTimeDebounceId: Hashable { }

        switch action {
        case let .setDate(date):
            return setDate(date, state: &state, environment: environment)
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
        case let .speechRecognizer(.setUtterance(utterance)):
            guard
                let utterance = utterance,
                let date = environment.recognizeTime(utterance, environment.calendar)
            else { return .none }
            // TODO: debounce?
            @Dependency(\.speechRecognizer) var speechRecognizer
            speechRecognizer.stopRecording()
            return setDate(date, state: &state, environment: environment)
        case .configuration: return .none
        case .tts: return .none
        case .speechRecognizer: return .none
        }
    }
)

private func setDate(_ date: Date, state: inout AppState, environment: AppEnvironment) -> EffectTask<AppAction> {
    state.date = date
    state.tellTime = environment.tellTime(date, environment.calendar)
    state.tts.text = state.tellTime ?? ""
    return .none
}

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
            calendar: Calendar.autoupdatingCurrent,
            tellTime: mockedTellTime,
            recognizeTime: { _, _ in nil },
            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
        modifyEnvironment(&environment)
        return environment
    }

    static var preview: Self { .preview() }
}

func mockedTellTime(date: Date, calendar: Calendar) -> String { "12:34" }
#endif
