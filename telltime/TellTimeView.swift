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
      time: self.store.state.tts.engine.time(date: self.date.wrappedValue),
      deviceOrientation: self.store.state.deviceOrientation,
      changeClockRandomly: { self.store.send(.clock(.changeClockRandomly)) }
    )
      .onAppear(perform: self.subscribe)
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
            self.landscapeBody
          } else {
            self.portraitBody
          }
        }
        .padding()
        .navigationBarTitle("Tell Time")

        self.configurationGearButton
      }
      .navigationBarItems(trailing: self.configurationGearButton)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  var portraitBody: some View {
    VStack {
      Spacer()
      ClockContainer()
      Spacer()
      self.timeText
      Spacer()
      DatePicker("", selection: self.$date, displayedComponents: [.hourAndMinute])
        .fixedSize()
      Spacer()
      self.buttons
    }
  }

  var landscapeBody: some View {
    HStack {
      VStack {
        ClockContainer()
          .padding()
        self.timeText
      }
      VStack {
        Spacer()
        DatePicker("", selection: self.$date, displayedComponents: [.hourAndMinute])
          .fixedSize()
        Spacer()
        self.buttons
      }
    }
  }

  private var buttons: some View {
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
      NavigationLink(destination: About()) {
        Image(systemName: "questionmark.circle")
          .padding()
          .accentColor(.red)
      }
    }
    .padding(Edge.Set.horizontal)
  }

  private var timeText: some View {
    Text(self.time)
      .font(.headline)
      .foregroundColor(.red)
  }

  private var configurationGearButton: some View {
    NavigationLink(destination: ConfigurationContainer()) {
      Image(systemName: "gear")
        .padding()
        .accentColor(.red)
    }
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TellTimeView(
      date: .constant(Date()),
      time: "It's time to test!",
      deviceOrientation: .portrait,
      changeClockRandomly: { print("Change Clock Randomly") }
    )
  }
}
#endif
