import SwiftUI
import ComposableArchitecture
import SwiftTTSCombine
import SwiftClockUI
import SwiftPastTen

@main
struct TellTimeUKApp: SwiftUI.App {
    struct ViewState: Equatable { }

    enum ViewAction {
        case setDateNow
        case setClockStyle(ClockStyle)
        case tellTime
    }
    
    let store: Store<AppState, AppAction> = Store(
        initialState: AppState(date: Date()),
        reducer: appReducer,
        environment: AppEnvironment(
            currentDate: { Date() },
            tts: TTSEnvironment(
                engine: Engine(),
                calendar: Calendar.autoupdatingCurrent,
                tellTime: {
                    let time = SwiftPastTen.formattedDate($0, calendar: $1)

                    guard let tellTime = try? SwiftPastTen().tell(time: time)
                    else { return "" }

                    return tellTime
                }
            ),
            speechRecognition: SpeechRecognitionEnvironment(
                engine: SpeechRecognitionSpeechEngine(),
                recognizeTime: SwiftToTen.recognizeTime,
                calendar: Calendar.autoupdatingCurrent
            )
        )
    )

    var body: some Scene {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            WindowGroup {
                MainView()
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
        case .setDateNow: return .changeDate(Date())
        case .tellTime: return .tts(.tellTime(Date()))
        case .setClockStyle(let clockStyle): return .configuration(.changeClockStyle(clockStyle))
        }
    }
}
