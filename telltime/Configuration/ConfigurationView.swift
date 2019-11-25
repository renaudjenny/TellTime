import SwiftUI
import Combine

struct ConfigurationContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    ConfigurationView(deviceOrientation: self.store.state.deviceOrientation)
  }
}

struct ConfigurationView: View {
  @EnvironmentObject var configuration: ConfigurationStore
  @EnvironmentObject var tts: TTS
  let deviceOrientation: UIDeviceOrientation

  var body: some View {
    Group {
      if self.deviceOrientation.isLandscape {
        self.landscapeBody
      } else {
        self.portraitBody
      }
    }
    .padding()
    .onReceive(self.configuration.$speechRateRatio, perform: { self.tts.rateRatio = $0 })
  }

  private var portraitBody: some View {
    VStack {
      self.stylePicker
      Clock()
        .padding()
      self.controls
      Spacer()
    }
  }

  private var landscapeBody: some View {
    HStack {
      VStack {
        Clock()
          .padding()
        self.stylePicker
      }
      self.controls
    }
  }

  private var controls: some View {
    VStack(spacing: 30.0) {
      HStack {
        Text("Speech rate: \(self.speechRateRatioPourcentage)%")
        Slider(value: self.$configuration.speechRateRatio, in: 0.5...1.0)
          .accentColor(.red)
      }
      Toggle(isOn: self.$configuration.showMinuteIndicators) {
        Text("Minute indicators")
      }
      Toggle(isOn: self.$configuration.showHourIndicators) {
        Text("Hour indicators")
      }
      .disabled(self.configuration.clockStyle == .artNouveau)
      Toggle(isOn: self.$configuration.showLimitedHourIndicators) {
        Text("Limited hour texts")
      }
    }
  }

  private var stylePicker: some View {
    Picker("Style", selection: self.$configuration.clockStyle) {
      ForEach(ClockStyle.allCases) { style in
        Text(style.description)
          .tag(style)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }

  private var speechRateRatioPourcentage: Int {
    Int(
      (self.configuration.speechRateRatio * 100)
        .rounded()
    )
  }
}

struct Configuration_Previews: PreviewProvider {
  static var previews: some View {
    ConfigurationView(deviceOrientation: .portrait)
      .environmentObject(ConfigurationStore())
      .environmentObject(ClockStore())
      .environmentObject(TTS())
  }
}
