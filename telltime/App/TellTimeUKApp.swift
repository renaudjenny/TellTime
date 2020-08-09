import SwiftUI
import SwiftTTSCombine

@main
struct TellTimeUKApp: SwiftUI.App {
    @StateObject private var store: Store<App.State, App.Action, App.Environment> = {
        let initialEnvironment = EnvironmentValues()
        let environment = App.Environment(
            currentDate: { Date() },
            tts: TTS.Environment(
                engine: Engine(),
                calendar: initialEnvironment.calendar,
                tellTime: initialEnvironment.tellTime
            )
        )
        return .init(
            initialState: App.State(date: Date()),
            reducer: App.reducer,
            environment: environment
        )
    }()

    var body: some Scene {
        WindowGroup {
            TellTimeView().environmentObject(store)
        }
    }
}
