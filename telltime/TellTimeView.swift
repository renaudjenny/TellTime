import SwiftUI
import Combine

struct TellTimeContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  private var date: Binding<Date> {
    self.store.binding(for: \.clock.date) { .clock(.changeDate($0)) }
  }

  var body: some View {
    TellTimeView(
      date: self.date,
      time: self.store.state.time,
      deviceOrientation: self.store.state.deviceOrientation,
      changeClockRandomly: self.changeClockRandomly
    )
      .onAppear(perform: self.subscribe)
  }

  private func changeClockRandomly() {
    self.store.send(.clock(.changeClockRandomly))
  }

  private func subscribe() {
    self.store.send(App.SideEffect.subscribeToOrientationChanged)
  }
}

struct TellTimeView: View {
  @Binding var date: Date
  let time: String
  let deviceOrientation: UIDeviceOrientation
  let changeClockRandomly: () -> Void

  var body: some View {
    NavigationView {
      VStack {
        Group {
          if self.deviceOrientation.isLandscape {
            LandscapeView(time: self.time, changeClockRandomly: self.changeClockRandomly, date: self.$date)
          } else {
            PortraitView(time: self.time, changeClockRandomly: self.changeClockRandomly, date: self.$date)
          }
        }
        .padding()
        .navigationBarTitle("Tell Time")
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

private struct PortraitView: View {
  let time: String
  let changeClockRandomly: () -> Void
  @Binding var date: Date

  var body: some View {
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
  }
}

private struct LandscapeView: View {
  let time: String
  let changeClockRandomly: () -> Void
  @Binding var date: Date

  var body: some View {
    HStack {
      VStack {
        ClockContainer()
          .padding()
        TimeText(time: self.time)
      }
      VStack {
        Spacer()
        DatePicker("", selection: self.$date, displayedComponents: [.hourAndMinute])
          .fixedSize()
        Spacer()
        TellTimeButtons(changeClockRandomly: self.changeClockRandomly)
      }
    }
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
      NavigationLink(destination: About()) {
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
      deviceOrientation: .portrait,
      changeClockRandomly: { print("Change Clock Randomly") }
    )
      .environmentObject(App.previewStore)
  }
}
#endif
