import SwiftUI
import ComposableArchitecture
import SwiftClockUI
import SwiftPastTen
import SwiftToTen

@main
struct TellTimeUKApp: SwiftUI.App {

    let store = Store(initialState: App.State(), reducer: App())

    var body: some Scene {
        WindowGroup {
            WithViewStore(store.stateless) { viewStore in
                MainView(store: store)
                    .onOpenURL(perform: { openURL($0, viewStore: viewStore) })
            }
        }
    }

    private func openURL(_ url: URL, viewStore: ViewStore<Void, App.Action>) {
        @Dependency(\.date) var date
        viewStore.send(.setDate(date.now))
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return }

        guard
            let clockStyleValue = urlComponents
                .queryItems?
                .first(where: { $0.name == "clockStyle" })?
                .value,
            let clockStyle = ClockStyle.allCases.first(where: { String($0.id) == clockStyleValue })
        else { return }
        viewStore.send(.configuration(.set(\.$clockStyle, clockStyle)))

        if urlComponents.queryItems?.first(where: { $0.name == "speak" })?.value == "true" {
            viewStore.send(.tts(.speak))
        }
    }
}
