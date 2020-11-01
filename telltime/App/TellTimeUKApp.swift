import SwiftUI
import SwiftTTSCombine
import SwiftClockUI

@main
struct TellTimeUKApp: SwiftUI.App {
    @StateObject private var store: Store<AppState, AppAction, AppEnvironment> = {
        let initialEnvironment = EnvironmentValues()
        let environment = AppEnvironment(
            currentDate: { Date() },
            tts: TTSEnvironment(
                engine: Engine(),
                calendar: initialEnvironment.calendar,
                tellTime: initialEnvironment.tellTime
            )
        )
        return .init(
            initialState: AppState(date: Date()),
            reducer: appReducer,
            environment: environment
        )
    }()

    var body: some Scene {
        WindowGroup {
            TellTimeView()
                .environmentObject(store)
                .onOpenURL(perform: { url in
                    store.send(.changeDate(Date()))
                    guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                        return
                    }
                    guard
                        let clockStyleValue = urlComponents
                            .queryItems?
                            .first(where: { $0.name == "clockStyle" })?
                            .value,
                        let clockStyle = ClockStyle.allCases.first(where: { String($0.id) == clockStyleValue })
                    else {
                        return
                    }
                    store.send(.configuration(.changeClockStyle(clockStyle)))
                    if urlComponents.queryItems?.first(where: { $0.name == "speak" })?.value == "true" {
                        store.send(.tts(.tellTime(Date())))
                    }
                })
        }
    }
}
