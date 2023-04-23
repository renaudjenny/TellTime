import ConfigurationFeature
import SwiftUI
import Combine
import Speech
import AVFoundation
import ComposableArchitecture
import SpeechRecognizerCore
import SwiftPastTenDependency
import SwiftToTenDependency
import TTSCore

public struct App: ReducerProtocol {
    public struct State: Equatable {
        var date: Date = Date()
        var configuration = Configuration.State()
        var tts = TTS.State()
        var speechRecognizer = SpeechRecognizer.State()
        var isAboutPresented = false
        var tellTime: String?
    }

    public enum Action: Equatable {
        case setDate(Date)
        case setRandomDate
        case configuration(Configuration.Action)
        case tts(TTS.Action)
        case speechRecognizer(SpeechRecognizer.Action)
        case appStarted
        case presentAbout
        case hideAbout
    }

    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar
    @Dependency(\.randomDate) var randomDate
    @Dependency(\.tellTime) var tellTime
    @Dependency(\.recognizeTime) var recognizeTime
    @Dependency(\.speechRecognizer) var speechRecognizer
    @Dependency(\.mainQueue) var mainQueue

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.configuration, action: /App.Action.configuration) {
            Configuration()
        }
        Scope(state: \.tts, action: /App.Action.tts) {
            TTS()
        }
        Scope(state: \.speechRecognizer, action: /App.Action.speechRecognizer) {
            SpeechRecognizer()
        }
        Reduce { state, action in
            struct RecognizedTimeDebounceId: Hashable { }

            switch action {
            case let .setDate(date):
                return setDate(date, state: &state)
            case .setRandomDate:
                let randomDate = randomDate()
                return setDate(randomDate, state: &state)
            case .appStarted:
                if state.tellTime == nil {
                    return setDate(state.date, state: &state)
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
                    let date = recognizeTime(time: utterance, calendar: calendar)
                else { return .none }
                speechRecognizer.stopRecording()
                return setDate(date, state: &state)
            case .configuration(.binding(\.$speechRateRatio)):
                @Dependency(\.tts) var tts
                tts.setRateRatio(state.configuration.speechRateRatio)
                return .none
            case .configuration: return .none
            case .tts: return .none
            case .speechRecognizer: return .none
            }
        }
    }

    private func setDate(_ date: Date, state: inout App.State) -> EffectTask<App.Action> {
        state.date = date
        let time = SwiftPastTen.formattedDate(date, calendar: calendar)
        state.tellTime = (try? tellTime(time: time)) ?? ""
        state.tts.text = state.tellTime ?? ""
        return .none
    }
}

public extension Store where State == App.State, Action == App.Action {
    static var live: StoreOf<App> { Store(initialState: App.State(), reducer: App()) }
}

#if DEBUG
extension Store where State == App.State, Action == App.Action {
    static func preview(modifyState: (inout App.State) -> Void = { _ in }) -> Self {
        let state: App.State = .preview(modifyState: modifyState)
        return Self(initialState: state, reducer: App())
    }

    static var preview: Self { preview() }
}

extension App.State {
    static func preview(
        modifyState: (inout App.State) -> Void = { _ in }
    ) -> Self {
        var state = App.State()
        modifyState(&state)
        return state
    }

    static var preview: Self { .preview() }
}
#endif
