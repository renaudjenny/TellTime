import SwiftUI
import ComposableArchitecture
import Combine
import SwiftClockUI
import RenaudJennyAboutView

struct MainView: View {
    struct ViewState: Equatable {
        var date: Date
        var recognizedUtterance: String?
    }

    enum ViewAction: Equatable {
        case setDate(Date)
    }

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    let store: Store<AppState, AppAction>

    @State private var isConfigurationShown: Bool = false
    @State private var isAboutShown: Bool = false

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
                clockView
                Spacer()
                TimeText()
                Spacer()
                DateSelector(store: store)
                Spacer()
                TellTimeButtons(store: store)
            } else if verticalSizeClass == .compact {
                HStack {
                    clockView.padding()
                    VStack {
                        TimeText()
                        Spacer()
                        DateSelector(store: store)
                        Spacer()
                        TellTimeButtons(store: store)
                    }
                }
            } else {
                VStack {
                    clockView.padding()
                    VStack {
                        TimeText()
                        DateSelector()
                    }
                    HStack {
                        Spacer()
                        TellTimeButtons(isConfigurationShown: $isConfigurationShown, isAboutShown: $isAboutShown)
                        Spacer()
                    }
                }
            }
            navigationLinks
        }
        .animation(.easeInOut)
    }

    private var clockView: some View {
        ClockView()
            .environment(\.clockDate, date)
            .environment(\.clockStyle, store.state.configuration.clockStyle)
            .environment(\.clockConfiguration, store.state.configuration.clock)
    }

    private var navigationLinks: some View {
        VStack {
            NavigationLink(destination: ConfigurationView(), isActive: $isConfigurationShown, label: EmptyView.init)
            NavigationLink(
                destination: AboutView(appId: "id1496541173") {
                    Image(uiImage: #imageLiteral(resourceName: "Logo")).shadow(radius: 5)
                },
                isActive: $isAboutShown,
                label: EmptyView.init
            )
        }
    }
}

private extension AppState {
    var view: MainView.ViewState {
        MainView.ViewState(
            date: date,
            recognizedUtterance: speechRecognition.utterance
        )
    }
}

private extension AppAction {
    static func view(localAction: MainView.ViewAction) -> Self {
        switch localAction {
        case .setDate(let date): return changeDate(date)
        }
    }
}

private struct TellTimeButtons: View {
    @Environment(\.randomDate) private var randomDate
    let store: Store<AppState, AppAction>

    var body: some View {
        HStack {
            SpeakButton(store: store)
            Spacer()
            Button(action: changeClockRandomly) {
                Image(systemName: "shuffle")
                    .padding()
                    .accentColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            Spacer()
            ConfigurationGearButton(isConfigurationShown: $isConfigurationShown)
            Spacer()
            Button(action: { isAboutShown.toggle() }, label: {
                Image(systemName: "questionmark.circle")
                    .padding()
                    .accentColor(.red)
            })
        }
        .frame(maxWidth: 800)
        .padding([.horizontal, .top])
    }

    private func changeClockRandomly() {
        store.send(.changeDate(randomDate(calendar)))
    }
}

private struct TimeText: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.tellTime) private var tellTime
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>

    var body: some View {
        Text(tellTime(store.state.date, calendar))
            .font(.title2)
            .foregroundColor(.red)
            .padding()
    }
}

private struct ConfigurationGearButton: View {
    @Binding var isConfigurationShown: Bool

    var body: some View {
        Button(action: { isConfigurationShown.toggle() }, label: {
            Image(systemName: "gear")
                .padding()
                .accentColor(.red)
        })
    }
}

#if DEBUG
struct TellTimeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TellTimeView()
                .environmentObject(previewStore { _ in })
            TellTimeView()
                .previewLayout(.fixed(width: 800, height: 400))
                .preferredColorScheme(.dark)
                .environmentObject(previewStore { _ in })
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
            TellTimeView()
                .previewLayout(.fixed(width: 1600, height: 1000))
                .environmentObject(previewStore { _ in })
                .environment(\.locale, Locale(identifier: "fr_FR"))
        }
    }
}
#endif
