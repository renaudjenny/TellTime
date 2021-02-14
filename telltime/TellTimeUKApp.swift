import SwiftUI
import ComposableArchitecture
import SwiftTTSCombine
import SwiftClockUI
import SwiftPastTen

@main
struct TellTimeUKApp: SwiftUI.App {
    struct ViewState: Equatable { }

    enum ViewAction: Equatable {
        case setDateNow
        case setClockStyle(ClockStyle)
        case tellTime
    }

    let store: Store<AppState, AppAction> = Store(
        initialState: AppState(date: Date()),
        reducer: appReducer,
        environment: AppEnvironment(
            currentDate: { Date() },
            randomDate: generateRandomDate,
            ttsEngine: Engine(),
            calendar: Calendar.autoupdatingCurrent,
            tellTime: tellTime,
            speechRecognitionEngine: SpeechRecognitionSpeechEngine(),
            recognizeTime: SwiftToTen.recognizeTime
        )
    )

    var body: some Scene {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            WindowGroup {
                MainView(store: store)
                    .onOpenURL(perform: { url in
                        viewStore.send(.setDateNow)
                        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
                        else { return }

                        guard let clockStyleValue = urlComponents
                                .queryItems?
                                .first(where: { $0.name == "clockStyle" })?
                                .value,
                              let clockStyle = ClockStyle.allCases.first(where: { String($0.id) == clockStyleValue })
                        else { return }
                        viewStore.send(.setClockStyle(clockStyle))

                        if urlComponents.queryItems?.first(where: { $0.name == "speak" })?.value == "true" {
                            viewStore.send(.tellTime)
                        }
                    })
            }
        }
    }
}

private extension AppState {
    var view: TellTimeUKApp.ViewState {
        TellTimeUKApp.ViewState()
    }
}

private extension AppAction {
    static func view(localAction: TellTimeUKApp.ViewAction) -> Self {
        switch localAction {
        case .setDateNow: return .setDate(Date())
        case .tellTime: return .tts(.tellTime(Date()))
        case .setClockStyle(let clockStyle): return .configuration(.setClockStyle(clockStyle))
        }
    }
}
