import SwiftUI
import Combine

// The name App could be confused with the SwiftUI name. Should be refactored to use AppStore name or something
enum App {
    struct State {
        var date: Date
        var configuration = Configuration.State()
        var tts = TTS.State()
    }

    enum Action {
        case changeDate(Date)
        case configuration(Configuration.Action)
        case tts(TTS.Action)
    }

    struct Environment {
        let currentDate: () -> Date
        let tts: TTS.Environment
    }

    static func reducer(
        state: inout App.State,
        action: App.Action,
        environment: App.Environment
    ) -> AnyPublisher<App.Action, Never>? {
        switch action {
        case let .changeDate(date):
            state.date = date
        case let .configuration(action):
            Configuration.reducer(state: &state.configuration, action: action)
        case let .tts(action):
            guard let effect = TTS.reducer(state: &state.tts, action: action, environment: environment.tts) else {
                return nil
            }
            return effect
                .map { App.Action.tts($0) }
                .eraseToAnyPublisher()
        }
        return nil
    }

    #if DEBUG
    static func previewStore(
        modifyState: (inout App.State) -> Void
    ) -> Store<App.State, App.Action, Environment> {
        let mockedEnvironment = Environment(
            currentDate: { .init(hour: 10, minute: 10, calendar: .preview) },
            tts: TTS.Environment(engine: MockedTTSEngine())
        )
        var state = App.State(date: mockedEnvironment.currentDate())
        _ = modifyState(&state)

        let mockedReducer: Reducer<App.State, App.Action, Environment> = { _, _, _ in nil }
        return .init(initialState: state, reducer: mockedReducer, environment: mockedEnvironment)
    }

    static let previewStore = App.previewStore { _ in }

    private final class MockedTTSEngine: TTSEngine {
        var rateRatio: Float = 1.0
        func speech(date: Date) { }
        var isSpeakingPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
        var speakingProgressPublisher: AnyPublisher<Double, Never> { Just(0.0).eraseToAnyPublisher() }
    }
    #endif
}
