import SwiftUI
import ComposableArchitecture
import SwiftClockUI
import SwiftPastTen
import SwiftToTen

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
            calendar: Calendar.autoupdatingCurrent,
            tellTime: tellTime,
            recognizeTime: SwiftToTen.recognizeTime,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
    )

    var body: some Scene {
        WindowGroup {
            WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
                MainView(store: store)
                    .onOpenURL(perform: { openURL($0, viewStore: viewStore) })
            }
        }
    }

    private func openURL(_ url: URL, viewStore: ViewStore<ViewState, ViewAction>) {
        viewStore.send(.setDateNow)
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return }

        guard
            let clockStyleValue = urlComponents
                .queryItems?
                .first(where: { $0.name == "clockStyle" })?
                .value,
            let clockStyle = ClockStyle.allCases.first(where: { String($0.id) == clockStyleValue })
        else { return }
        viewStore.send(.setClockStyle(clockStyle))

        if urlComponents.queryItems?.first(where: { $0.name == "speak" })?.value == "true" {
            viewStore.send(.tellTime)
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
        case .tellTime: return .tts(.speak)
        case .setClockStyle(let clockStyle): return .configuration(.binding(.set(\.$clockStyle, clockStyle)))
        }
    }
}
