import SwiftUI
import Combine
import SwiftPastTen

struct TellTime: View {
  @EnvironmentObject private var store: Store
  @State private var deviceOrientation = UIDevice.current.orientation
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()

  var body: some View {
    Group {
      if self.deviceOrientation.isLandscape {
        self.landscapeBody
      } else {
        self.portraitBody
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { notification in
      guard let device = notification.object as? UIDevice else { return }
      guard device.orientation.isValidInterfaceOrientation else { return }

      let isPhoneUpsideDown = device.orientation == .portraitUpsideDown && device.userInterfaceIdiom == .phone
      guard !isPhoneUpsideDown else { return }

      self.deviceOrientation = device.orientation
    }
    .onTapGesture(count: 3) {
      self.store.showClockFace = true
    }
  }

  var portraitBody: some View {
    NavigationView {
      VStack {
        Spacer()
        Clock(date: self.$store.date, showClockFace: self.store.showClockFace)
        Spacer()
        self.time
        Spacer()
        DatePicker("", selection: self.$store.date, displayedComponents: [.hourAndMinute])
          .fixedSize()
        Spacer()
        self.buttons
      }
      .padding()
      .navigationBarTitle("Tell Time")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  var landscapeBody: some View {
    NavigationView {
      HStack {
        VStack {
          Clock(date: self.$store.date, showClockFace: self.store.showClockFace)
            .padding()
          self.time
        }
        VStack {
          Spacer()
          DatePicker("", selection: self.$store.date, displayedComponents: [.hourAndMinute])
            .fixedSize()
          Spacer()
          self.buttons
        }
      }
      .padding()
      .navigationBarTitle("Tell Time")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  var buttons: some View {
    HStack {
      Button(action: self.tellTime) {
        Image(systemName: "speaker.2")
          .padding()
          .accentColor(.white)
          .background(self.store.isSpeaking ? Color.gray : Color.red)
          .cornerRadius(8)
      }
        .disabled(self.store.isSpeaking)
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
  }

  var time: some View {
    let time = try? tellTimeEngine.tell(time: DigitalTime.from(date: self.store.date))
    return Text(time ?? "")
      .font(.headline)
      .foregroundColor(.red)
  }

  func changeClockRandomly() {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0

    let newDate = Calendar.current.date(
      byAdding: DateComponents(hour: hour, minute: minute),
      to: self.store.date
    )
    self.store.date = newDate ?? self.store.date
  }

  func tellTime() {
    self.store.tts.speech(text: DigitalTime.from(date: self.store.date))
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      let store = Store()
      store.subscribers.forEach({ $0.cancel() })
      return TellTime().environmentObject(store)
    }
}
#endif
