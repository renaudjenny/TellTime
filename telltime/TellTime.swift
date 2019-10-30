import SwiftUI
import Combine
import SwiftPastTen

struct TellTime: View {
  @ObservedObject var viewModel: TellTimeViewModel

  var body: some View {
    NavigationView {
      Group {
        if self.viewModel.deviceOrientation.isLandscape {
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
    .onTapGesture(count: 3, perform: self.viewModel.showClockFace)
  }

  var portraitBody: some View {
    VStack {
      Spacer()
      Clock(viewModel: ClockViewModel(
        date: self.$viewModel.date,
        showClockFace: self.viewModel.isClockFaceShown
      ))
      Spacer()
      self.time
      Spacer()
      DatePicker("", selection: self.$viewModel.date, displayedComponents: [.hourAndMinute])
        .fixedSize()
      Spacer()
      self.buttons
    }
  }

  var landscapeBody: some View {
    HStack {
      VStack {
        Clock(viewModel: ClockViewModel(
          date: self.$viewModel.date,
          showClockFace: self.viewModel.isClockFaceShown
        ))
          .padding()
        self.time
      }
      VStack {
        Spacer()
        DatePicker("", selection: self.$viewModel.date, displayedComponents: [.hourAndMinute])
          .fixedSize()
        Spacer()
        self.buttons
      }
    }
  }

  private var buttons: some View {
    HStack {
      SpeakButton(
        action: self.viewModel.tellTime,
        progress: self.viewModel.speakingProgress,
        isSpeaking: self.viewModel.isSpeaking
      )
      Spacer()
      Button(action: self.viewModel.changeClockRandomly) {
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
    Text(self.viewModel.time)
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
    TellTime(viewModel: TellTimeViewModel(
      configuration: ConfigurationStore()
    ))
  }
}
#endif
