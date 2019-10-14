import SwiftUI
import Combine
import SwiftPastTen

struct TellTime: View {
  @ObservedObject var viewModel = TellTimeViewModel()

  var body: some View {
    Group {
      if self.viewModel.deviceOrientation.isLandscape {
        self.landscapeBody
      } else {
        self.portraitBody
      }
    }
    .onTapGesture(count: 3, perform: self.viewModel.showClockFace)
  }

  var portraitBody: some View {
    NavigationView {
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
      .padding()
      .navigationBarTitle("Tell Time")
      .navigationBarItems(trailing: NavigationLink(destination: Configuration()) {
        Image(systemName: "gear")
          .padding()
          .accentColor(.red)
      })
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  var landscapeBody: some View {
    NavigationView {
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
      .padding()
      .navigationBarTitle("Tell Time")
      .navigationBarItems(trailing: NavigationLink(destination: Configuration()) {
        Image(systemName: "gear")
          .padding()
          .accentColor(.red)
      })
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  var buttons: some View {
    HStack {
      Button(action: self.viewModel.tellTime) {
        Image(systemName: "speaker.2")
          .padding()
          .accentColor(.white)
          .background(self.viewModel.isSpeaking ? Color.gray : Color.red)
          .cornerRadius(8)
      }
      .disabled(self.viewModel.isSpeaking)
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
  }

  var time: some View {
    return Text(self.viewModel.time)
      .font(.headline)
      .foregroundColor(.red)
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    return TellTime()
  }
}
#endif
