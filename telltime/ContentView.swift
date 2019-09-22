import SwiftUI
import Combine

struct ContentView: View {
  @EnvironmentObject var store: Store

  var body: some View {
    Group {
      if store.deviceOrientation.isLandscape {
        self.landscapeBody
      } else {
        self.portraitBody
      }
    }
  }

  var portraitBody: some View {
    NavigationView {
      VStack {
        Clock()
        DatePicker("", selection: self.$store.date, displayedComponents: [.hourAndMinute])
          .fixedSize()
        self.buttons
      }
      .padding()
      .navigationBarTitle("Tell Time")
    }
  }

  var landscapeBody: some View {
    NavigationView {
      HStack {
        Clock()
          .padding()
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
  }

  var buttons: some View {
    ZStack {
      HStack {
        Spacer()
        Button(action: { self.changeClockRandomly() }) {
          Image(systemName: "shuffle")
            .padding()
            .accentColor(.white)
            .background(Color.red)
            .cornerRadius(8)
        }
        Spacer()
      }
      HStack {
        Spacer()
        NavigationLink(destination: About()) {
          Image(systemName: "questionmark.circle")
            .padding()
            .accentColor(.red)
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
