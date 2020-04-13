import SwiftUI
import Combine
import SwiftClockUI

struct RootView: View {
    @Environment(\.date) var date
    @Environment(\.tellTime) var tellTime
    @Environment(\.calendar) var calendar

    var body: some View {
        NavigationView {
            TellTimeView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(store)
    }

    private var environment: App.Environment {
        // Only use variable provided by @Environment to share
        // the same Environments between View and Store
        App.Environment(
            currentDate: date,
            tts: TTS.Environment(engine: TTS.Engine(tellTime: tellTime, calendar: calendar))
        )
    }

    private var store: Store<App.State, App.Action, App.Environment> {
        Store<App.State, App.Action, App.Environment>(
            initialState: App.State(date: environment.currentDate()),
            reducer: App.reducer,
            environment: environment
        )
    }
}
