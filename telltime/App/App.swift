import SwiftUI
import Combine
import SwiftTTSCombine
import AVFoundation

struct AppState {
    var date: Date
    var configuration = ConfigurationState()
    var tts = TTSState()
}

enum AppAction {
    case changeDate(Date)
    case configuration(ConfigurationAction)
    case tts(TTSAction)
}

struct AppEnvironment {
    let currentDate: () -> Date
    let tts: TTSEnvironment
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
    }
    return nil
}

#if DEBUG
func previewStore(
    modifyState: (inout AppState) -> Void
) -> Store<AppState, AppAction, AppEnvironment> {
    let mockedEnvironment = AppEnvironment(
        currentDate: { .init(hour: 10, minute: 10, calendar: .preview) },
        tts: TTSEnvironment(engine: MockedTTSEngine(), calendar: .preview, tellTime: mockedTellTime)
    )
    var state = AppState(date: mockedEnvironment.currentDate())
    _ = modifyState(&state)

    let mockedReducer: Reducer<AppState, AppAction, AppEnvironment> = { _, _, _ in nil }
    return .init(initialState: state, reducer: mockedReducer, environment: mockedEnvironment)
}

private final class MockedTTSEngine: TTSEngine {
    var rateRatio: Float = 1.0
    var voice: AVSpeechSynthesisVoice?
    func speak(string: String) { }
    var isSpeakingPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
    var speakingProgressPublisher: AnyPublisher<Double, Never> { Just(0.0).eraseToAnyPublisher() }
}

func mockedTellTime(date: Date, calendar: Calendar) -> String { "12:34" }
#endif
