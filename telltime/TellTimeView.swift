import SwiftUI
import Combine
import SwiftClockUI

struct TellTimeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>
    @State private var isConfigurationShown: Bool = false
    @State private var isAboutShown: Bool = false
    private var date: Binding<Date> { store.binding(for: \.date) { .changeDate($0) } }

    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Tell Time")
                .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var content: some View {
        VStack {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                Spacer()
                clockView
                Spacer()
                TimeText()
                Spacer()
                DatePicker()
                Spacer()
                TellTimeButtons(isConfigurationShown: $isConfigurationShown, isAboutShown: $isAboutShown)
            } else if verticalSizeClass == .compact {
                HStack {
                    clockView.padding()
                    VStack {
                        TimeText().padding()
                        DatePicker()
                        Spacer()
                        TellTimeButtons(isConfigurationShown: $isConfigurationShown, isAboutShown: $isAboutShown)
                    }
                }
            } else {
                HStack {
                    clockView
                        .layoutPriority(1)
                        .padding()
                    VStack {
                        Spacer()
                        TimeText().padding()
                        DatePicker()
                        Spacer()
                        TellTimeButtons(isConfigurationShown: $isConfigurationShown, isAboutShown: $isAboutShown)
                    }
                }
            }
            navigationLinks
        }
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
            NavigationLink(destination: AboutView(), isActive: $isAboutShown, label: EmptyView.init)
        }
    }
}

private struct DatePicker: View {
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>
    private var date: Binding<Date> {
        store.binding(for: \.date) { .changeDate($0) }
    }

    var body: some View {
        SwiftUI.DatePicker("", selection: self.date, displayedComponents: [.hourAndMinute])
            .datePickerStyle(WheelDatePickerStyle())
    }
}

private struct TellTimeButtons: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.randomDate) private var randomDate
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>
    @Binding var isConfigurationShown: Bool
    @Binding var isAboutShown: Bool

    var body: some View {
        HStack {
            SpeakButton()
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
        .padding(.horizontal)
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
            .font(.headline)
            .foregroundColor(.red)
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
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .regular)
            TellTimeView()
                .previewLayout(.fixed(width: 800, height: 400))
                .preferredColorScheme(.dark)
                .environmentObject(previewStore { _ in })
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
        }
    }
}
#endif
