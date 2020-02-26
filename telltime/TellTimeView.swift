import SwiftUI
import Combine
import SwiftClockUI

struct RootView: View {
  var body: some View {
    NavigationView {
      TellTimeView()
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct TellTimeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var store: Store<App.State, App.Action>
    private var date: Binding<Date> {
        self.store.binding(for: \.clock.date) { .clock(.changeDate($0)) }
    }

    var body: some View {
        Group {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                verticalView
            } else if verticalSizeClass == .compact {
                compactView
            } else {
                regularView
            }
        }
        .navigationBarTitle("Tell Time")
        .padding()
    }

    private var clockView: some View {
        ClockView()
            .environment(\.clockDate, date)
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
    @EnvironmentObject var store: Store<App.State, App.Action>
    private var date: Binding<Date> {
        store.binding(for: \.clock.date) { .clock(.changeDate($0)) }
    }

    var body: some View {
        SwiftUI.DatePicker("", selection: self.date, displayedComponents: [.hourAndMinute])
            .fixedSize()
    }
}

private struct TellTimeButtons: View {
    @EnvironmentObject var store: Store<App.State, App.Action>

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
        store.send(.clock(.changeClockRandomly))
    }
}

private struct TimeText: View {
    @EnvironmentObject var store: Store<App.State, App.Action>

    var body: some View {
        Text(Current.tellTime(store.state.clock.date))
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
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TellTimeView()
      .environmentObject(App.previewStore)
  }
}
#endif
