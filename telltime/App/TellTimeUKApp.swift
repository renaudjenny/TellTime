import SwiftUI
import SwiftTTSCombine

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
                    switch url.absoluteString {
                    case "speak":
                        store.send(.tts(.tellTime(Date())))
                    default: break
                    }
                })
        }
    }
}
