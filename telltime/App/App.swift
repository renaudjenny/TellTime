import SwiftUI
import Combine

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
            guard let effect = TTS.reducer(state: &state.tts, action: action, environment: TTS.Environment()) else {
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
            currentDate: { .init(hour: 10, minute: 10, calendar: .previewCalendar) }
        )
        var state = App.State(date: mockedEnvironment.currentDate())
        _ = modifyState(&state)

        let mockedReducer: Reducer<App.State, App.Action, Environment> = { _, _, _ in nil }
        return .init(initialState: state, reducer: mockedReducer, environment: mockedEnvironment)
    }

    static let previewStore = App.previewStore { _ in }
    #endif
}

// TODO: move this to its own file
#if DEBUG
extension Calendar {
    static var previewCalendar: Self {
        var calendar = Self(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar
    }
}
#endif
