import SwiftUI
import Combine
import SwiftClockUI

struct TellTimeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var store: Store<App.State, App.Action, App.Environment>
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
            } else if verticalSizeClass == .compact {
                HStack {
                    clockView.padding()
                    VStack {
                        TimeText().padding()
                        DatePicker()
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
                    }
                }
            }
            TellTimeButtons()
        }
    }

    private var clockView: some View {
        ClockView()
            .environment(\.clockDate, date)
            .environment(\.clockStyle, store.state.configuration.clockStyle)
            .environment(\.clockConfiguration, store.state.configuration.clock)
    }
}

private struct DatePicker: View {
    @EnvironmentObject var store: Store<App.State, App.Action, App.Environment>
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
    @EnvironmentObject var store: Store<App.State, App.Action, App.Environment>

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
            ConfigurationGearButton()
            Spacer()
            NavigationLink(destination: AboutView()) {
                Image(systemName: "questionmark.circle")
                    .padding()
                    .accentColor(.red)
            }
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
    @EnvironmentObject var store: Store<App.State, App.Action, App.Environment>

    var body: some View {
        Text(tellTime(store.state.date, calendar))
            .font(.headline)
            .foregroundColor(.red)
    }
}

private struct ConfigurationGearButton: View {
    var body: some View {
        NavigationLink(destination: ConfigurationView()) {
            Image(systemName: "gear")
                .padding()
                .accentColor(.red)
        }
    }
}

#if DEBUG
struct TellTimeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TellTimeView()
                .environmentObject(App.previewStore)
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .regular)
            TellTimeView()
                .previewLayout(.fixed(width: 800, height: 400))
                .preferredColorScheme(.dark)
                .environmentObject(App.previewStore)
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
        }
    }
}
#endif
