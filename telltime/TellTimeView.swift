import SwiftUI
import Combine

struct TellTimeContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  @State private var date: Date = Date()// self.store.state.clock.date

  var body: some View {
    TellTimeView(
      date: self.$date,
      time: self.time,
      deviceOrientation: self.store.state.deviceOrientation,
      changeClockRandomly: { self.store.send(.clock(action: .changeClockRandomly)) }
    )
      .onTapGesture(count: 3, perform: self.showClockFace)
      .onAppear(perform: self.subscribe)
      // FIXME .onReceive(self.datePublisher, perform: self.tts.speech)
  }

  private var time: String {
    self.store.state.tts.engine.time(date: self.date)
  }

  private var datePublisher: AnyPublisher<Date, Never> {
    self.store.$state
      .map(\.clock.date)
      .eraseToAnyPublisher()
  }

  private func subscribe() {
    self.store.send(App.SideEffect.subscribeToOrientationChanged)
  }

  private func showClockFace() {
    self.store.send(App.Action.clock(action: .showClockFace))
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
