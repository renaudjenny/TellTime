import ConfigurationFeature
import SwiftUI
import ComposableArchitecture
import Combine
import SwiftClockUI
import RenaudJennyAboutView

public struct AppView: View {
    public struct ViewState: Equatable {
        var date: Date
        var time: String?
        var recognizedUtterance: String?
        var clockStyle: ClockStyle
        var clockConfiguration: ClockConfiguration
        var isConfigurationPresented: Bool
        var isAboutPresented: Bool

        init(_ state: App.State) {
            date = state.date
            time = state.tellTime
            recognizedUtterance = state.speechRecognizer.utterance
            clockStyle = state.configuration.clockStyle
            clockConfiguration = state.configuration.clock
            isConfigurationPresented = state.configuration.isPresented
            isAboutPresented = state.isAboutPresented
        }
    }

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    let store: StoreOf<App>

    public init(store: StoreOf<App>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.stateless) { viewStore in
            NavigationView {
                content
                    .navigationBarTitle("Tell Time")
                    .padding()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear { viewStore.send(.appStarted) }
            .onOpenURL(perform: { openURL($0, viewStore: viewStore) })
        }
    }

    private var content: some View {
        VStack {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                Spacer()
                clockView
                Spacer()
                timeText
                Spacer()
                DateSelector(store: store)
                Spacer()
                Buttons(store: store)
            } else if verticalSizeClass == .compact {
                HStack {
                    clockView.padding()
                    VStack {
                        timeText
                        Spacer()
                        DateSelector(store: store)
                        Spacer()
                        Buttons(store: store)
                    }
                }
            } else {
                VStack {
                    clockView
                    VStack {
                        timeText
                        DateSelector(store: store)
                    }
                    HStack {
                        Spacer()
                        Buttons(store: store)
                        Spacer()
                    }
                }
            }
            navigationLinks
        }
    }

    private var clockView: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ClockView()
                .environment(\.clockDate, viewStore.binding(get: \.date, send: App.Action.setDate))
                .environment(\.clockStyle, viewStore.clockStyle)
                .environment(\.clockConfiguration, viewStore.clockConfiguration)
        }
    }

    private var timeText: some View {
        WithViewStore(store, observe: { $0.tellTime }) { viewStore in
            viewStore.state.map { time in
                Text(time)
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    private var navigationLinks: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack {
                NavigationLink(
                    destination: ConfigurationView(store: store.scope(
                        state: \.configuration,
                        action: { App.Action.configuration($0) }
                    )),
                    isActive: viewStore.binding(get: \.isConfigurationPresented, send: App.Action.configuration(.hide)),
                    label: EmptyView.init
                )
                NavigationLink(
                    destination: AboutView(appId: "id1496541173") {
                        Image(uiImage: #imageLiteral(resourceName: "Logo")).shadow(radius: 5)
                    },
                    isActive: viewStore.binding(get: \.isAboutPresented, send: App.Action.hideAbout),
                    label: EmptyView.init
                )
            }
        }
    }

    // TODO: logic to move in the reducer
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

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppView(store: .preview)
            AppView(store: .preview)
                .previewLayout(.fixed(width: 800, height: 400))
                .preferredColorScheme(.dark)
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
            AppView(store: .preview)
                .previewLayout(.fixed(width: 1600, height: 1000))
                .environment(\.locale, Locale(identifier: "fr_FR"))
        }
    }
}
#endif
