import SwiftUI
import Combine

struct RootView: View {
  var body: some View {
    NavigationView {
      TellTimeContainer()
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct TellTimeContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  private var date: Binding<Date> {
    self.store.binding(for: \.clock.date) { .clock(.changeDate($0)) }
  }

  var body: some View {
    TellTimeView(
      date: self.date,
      time: self.store.state.time,
      changeClockRandomly: self.changeClockRandomly
    )
  }

  private func changeClockRandomly() {
    self.store.send(.clock(.changeClockRandomly))
  }
}

struct TellTimeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Binding var date: Date
    let time: String
    let changeClockRandomly: () -> Void

    var body: some View {
        Group {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                VStack {
                    Spacer()
                    ClockContainer()
                    Spacer()
                    TimeText(time: self.time)
                    Spacer()
                    DatePicker("", selection: self.$date, displayedComponents: [.hourAndMinute])
                        .fixedSize()
                    Spacer()
                    TellTimeButtons(changeClockRandomly: self.changeClockRandomly)
                }
            } else if verticalSizeClass == .compact {
                HStack {
                    ClockContainer().padding()
                    VStack {
                        TimeText(time: self.time)
                            .padding()
                        DatePicker("", selection: self.$date, displayedComponents: [.hourAndMinute])
                            .fixedSize()
                        Spacer()
                        TellTimeButtons(changeClockRandomly: self.changeClockRandomly)
                    }
                }
            } else {
                HStack {
                    ClockContainer()
                        .layoutPriority(1)
                        .padding()
                    VStack {
                        Spacer()
                        TimeText(time: self.time)
                            .padding()
                        DatePicker("", selection: self.$date, displayedComponents: [.hourAndMinute])
                            .fixedSize()
                        Spacer()
                        TellTimeButtons(changeClockRandomly: self.changeClockRandomly)
                    }
                }
            }
        }
        .navigationBarTitle("Tell Time")
        .padding()
    }
}

private struct TellTimeButtons: View {
  let changeClockRandomly: () -> Void

  var body: some View {
    HStack {
      SpeakButtonContainer()
      Spacer()
      Button(action: self.changeClockRandomly) {
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
}

private struct TimeText: View {
  let time: String

  var body: some View {
    Text(self.time)
      .font(.headline)
      .foregroundColor(.red)
  }
}

private struct ConfigurationGearButton: View {
  var body: some View {
    NavigationLink(destination: ConfigurationContainer()) {
      Image(systemName: "gear")
        .padding()
        .accentColor(.red)
    }
  }
}

extension App.State {
  var time: String {
    TTS.time(date: self.clock.date)
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TellTimeView(
      date: .constant(.init(timeIntervalSince1970: 4300)),
      time: "It's time to test!",
      changeClockRandomly: { print("Change Clock Randomly") }
    )
      .environmentObject(App.previewStore)
  }
}
#endif
