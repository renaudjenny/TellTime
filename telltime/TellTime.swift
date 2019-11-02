import SwiftUI
import Combine
import SwiftPastTen

struct TellTime: View {
  @EnvironmentObject var configuration: ConfigurationStore
  @EnvironmentObject var clock: ClockStore
  @EnvironmentObject var tts: TTS

  var body: some View {
    NavigationView {
      Group {
        if self.configuration.deviceOrientation.isLandscape {
          self.landscapeBody
        } else {
          self.portraitBody
        }
      }
      .padding()
      .navigationBarTitle("Tell Time")
      .navigationBarItems(trailing: self.configurationGearButton)
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .onTapGesture(count: 3, perform: { self.clock.showClockFace = true })
    .onReceive(self.clock.$date, perform: self.tts.speech)
  }

  var portraitBody: some View {
    VStack {
      Spacer()
      Clock()
      Spacer()
      self.time
      Spacer()
      DatePicker("", selection: self.$clock.date, displayedComponents: [.hourAndMinute])
        .fixedSize()
      Spacer()
      self.buttons
    }
  }

  var landscapeBody: some View {
    HStack {
      VStack {
        Clock()
          .padding()
        self.time
      }
      VStack {
        Spacer()
        DatePicker("", selection: self.$clock.date, displayedComponents: [.hourAndMinute])
          .fixedSize()
        Spacer()
        self.buttons
      }
    }
  }

  private var buttons: some View {
    HStack {
      SpeakButton()
      Spacer()
      Button(action: self.clock.changeClockRandomly) {
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

  private var time: some View {
    Text(self.tts.time(date: self.clock.date))
      .font(.headline)
      .foregroundColor(.red)
  }

  private var configurationGearButton: some View {
    NavigationLink(destination: Configuration()) {
      Image(systemName: "gear")
        .padding()
        .accentColor(.red)
    }
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TellTime()
  }
}
#endif
