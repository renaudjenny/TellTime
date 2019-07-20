import SwiftUI
import Combine

struct ContentView: View {
  @EnvironmentObject var store: Store

  var body: some View {
    VStack {
      Clock()
        .padding()
      DatePicker("Time", selection: self.$store.date, displayedComponents: [.hourAndMinute])
      Button(action: {
        self.changeClockRandomly()
      }) {
        Text("Change time")
      }
    }
      .onAppear(perform: self.setupTTS)
  }

  func changeClockRandomly() {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0
    print("", (hour, minute))
    self.store.hour = hour
    self.store.minute = minute
  }

  private func setupTTS() {
    _ = self.store.willChange
      .debounce(for: .milliseconds(1500), scheduler: RunLoop.main)
      .sink { store in
        TTS(hour: self.store.hour, minute: self.store.minute)
          .speechTime()
      }
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
