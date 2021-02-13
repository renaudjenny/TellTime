import SwiftUI
import ComposableArchitecture
import Combine
import SwiftClockUI
import RenaudJennyAboutView

struct MainView: View {
    struct ViewState: Equatable {
        var date: Date
        var time: String
        var recognizedUtterance: String?
        var clockStyle: ClockStyle
        var clockConfiguration: ClockConfiguration
        var isConfigurationPresented: Bool
        var isAboutPresented: Bool
    }

    enum ViewAction: Equatable {
        case setDate(Date)
        case hideAbout
        case hideConfiguration
    }

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            NavigationView {
                content(viewStore: viewStore)
                    .navigationBarTitle("Tell Time")
                    .padding()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func content(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        VStack {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                Spacer()
                clockView(viewStore: viewStore)
                Spacer()
                timeText(viewStore: viewStore)
                Spacer()
                DateSelector(store: store)
                Spacer()
                Buttons(store: store)
            } else if verticalSizeClass == .compact {
                HStack {
                    clockView(viewStore: viewStore).padding()
                    VStack {
                        timeText(viewStore: viewStore)
                        Spacer()
                        DateSelector(store: store)
                        Spacer()
                        Buttons(store: store)
                    }
                }
            } else {
                VStack {
                    clockView(viewStore: viewStore).padding()
                    VStack {
                        timeText(viewStore: viewStore)
                        DateSelector(store: store)
                    }
                    HStack {
                        Spacer()
                        Buttons(store: store)
                        Spacer()
                    }
                }
            }
            navigationLinks(viewStore: viewStore)
        }
        .animation(.easeInOut)
    }

    private func clockView(viewStore: ViewStore<MainView.ViewState, MainView.ViewAction>) -> some View {
        ClockView()
            .environment(\.clockDate, viewStore.binding(get: \.date, send: MainView.ViewAction.setDate))
            .environment(\.clockStyle, viewStore.clockStyle)
            .environment(\.clockConfiguration, viewStore.clockConfiguration)
    }

    private func timeText(viewStore: ViewStore<MainView.ViewState, MainView.ViewAction>) -> some View {
        Text(viewStore.time)
            .font(.title2)
            .foregroundColor(.red)
            .padding()
    }

    private func navigationLinks(viewStore: ViewStore<MainView.ViewState, MainView.ViewAction>) -> some View {
        VStack {
            NavigationLink(
                destination: ConfigurationView(store: store),
                isActive: viewStore.binding(get: \.isConfigurationPresented, send: ViewAction.hideConfiguration),
                label: EmptyView.init
            )
            NavigationLink(
                destination: AboutView(appId: "id1496541173") {
                    Image(uiImage: #imageLiteral(resourceName: "Logo")).shadow(radius: 5)
                },
                isActive: viewStore.binding(get: \.isAboutPresented, send: ViewAction.hideAbout),
                label: EmptyView.init
            )
        }
    }
}

private extension AppState {
    var view: MainView.ViewState {
        MainView.ViewState(
            date: date,
            time: tellTime ?? NSLocalizedString(
                "Change the time to display something here.",
                comment: "Placeholder where the TellTime text will appear."
            ),
            recognizedUtterance: speechRecognition.utterance,
            clockStyle: configuration.clockStyle,
            clockConfiguration: configuration.clock,
            isConfigurationPresented: configuration.isPresented,
            isAboutPresented: isAboutPresented
        )
    }
}

private extension AppAction {
    static func view(localAction: MainView.ViewAction) -> Self {
        switch localAction {
        case .setDate(let date): return changeDate(date)
        case .hideAbout: return hideAbout
        case .hideConfiguration: return configuration(.hide)
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(store: .preview)
            MainView(store: .preview)
                .previewLayout(.fixed(width: 800, height: 400))
                .preferredColorScheme(.dark)
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
            MainView(store: .preview)
                .previewLayout(.fixed(width: 1600, height: 1000))
                .environment(\.locale, Locale(identifier: "fr_FR"))
        }
    }
}
#endif
