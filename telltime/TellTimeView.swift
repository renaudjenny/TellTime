import SwiftUI
import Combine
import SwiftClockUI

struct TellTimeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var store: Store<App.State, App.Action, App.Environment>
    private var date: Binding<Date> {
        self.store.binding(for: \.date) { .changeDate($0) }
    }

    var body: some View {
        NavigationView {
            responsiveView
            .navigationBarTitle("Tell Time")
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var responsiveView: some View {
        Group {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                verticalView
            } else if verticalSizeClass == .compact {
                compactView
            } else {
                regularView
            }
        }
    }

    private var clockView: some View {
        ClockView()
            .environment(\.clockDate, date)
            .environment(\.clockStyle, store.state.configuration.clockStyle)
            .environment(\.clockConfiguration, store.state.configuration.clock)
    }

    private var verticalView: some View {
        VStack {
            Spacer()
            clockView
            Spacer()
            TimeText()
            Spacer()
            DatePicker()
            Spacer()
            TellTimeButtons()
        }
    }

    private var compactView: some View {
        HStack {
            clockView.padding()
            VStack {
                TimeText().padding()
                DatePicker()
                Spacer()
                TellTimeButtons()
            }
        }
    }

    private var regularView: some View {
        HStack {
            clockView
                .layoutPriority(1)
                .padding()
            VStack {
                Spacer()
                TimeText().padding()
                DatePicker()
                Spacer()
                TellTimeButtons()
            }
        }
    }
}

private struct DatePicker: View {
    @EnvironmentObject var store: Store<App.State, App.Action, App.Environment>
    private var date: Binding<Date> {
        store.binding(for: \.date) { .changeDate($0) }
    }

    var body: some View {
        SwiftUI.DatePicker("", selection: self.date, displayedComponents: [.hourAndMinute])
            .fixedSize()
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
        .padding(Edge.Set.horizontal)
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
