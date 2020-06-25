import SwiftUI

@main
struct TellTimeUKApp: SwiftUI.App {
    @StateObject private var store: Store<App.State, App.Action, App.Environment> = {
        let initialEnvironment = EnvironmentValues()
        let ttsEngine = TTS.Engine(tellTime: initialEnvironment.tellTime, calendar: initialEnvironment.calendar)
        let environment = App.Environment(
            currentDate: { Date() },
            tts: TTS.Environment(engine: ttsEngine)
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
