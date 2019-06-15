import SwiftUI

struct ContentView: View {
  @EnvironmentObject var store: Store

  var digitalTime: String {
    let minute = self.store.minute > 9 ? "\(self.store.minute)" : "0\(self.store.minute)"
    return "\(self.store.hour):\(minute)"
  }

  var body: some View {
    let clock = Clock()
    let button = Button(action: {
      self.changeClockRandomly()
    }) {
      Text("Change time")
    }

    return VStack {
      Spacer()
      Text(self.digitalTime)
      clock
      DatePicker(self.$store.date)
      button
    }
  }

  func changeClockRandomly() {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0
    self.store.hour = hour
    self.store.minute = minute
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
