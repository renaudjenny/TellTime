import SwiftUI
import Combine

struct ContentView: View {
  @EnvironmentObject var store: Store

  var body: some View {
//    if UIDevice.current.orientation.isLandscape {
      return self.landscapeBody
//    } else {
//      return self.portraitBody
//    }
  }

  var portraitBody: some View {
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
  }

  var landscapeBody: some View {
    HStack {
      Clock()
        .padding()
      VStack {
        DatePicker("Time", selection: self.$store.date, displayedComponents: [.hourAndMinute])
        Button(action: {
          self.changeClockRandomly()
        }) {
          Text("Change time")
        }
      }
    }
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
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
