import SwiftUI

struct Configuration: View {
  static let timestampFor10to2: TimeInterval = 3000
  @ObservedObject var viewModel = ConfigurationViewModel()
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    Group {
      if self.viewModel.deviceOrientation.isLandscape {
        self.landscapeBody
      } else {
        self.portraitBody
      }
    }
    .padding()
  }

  private var portraitBody: some View {
    VStack {
      self.stylePicker
      Clock(viewModel: ClockViewModel(
        date: .constant(Date(timeIntervalSince1970: Self.timestampFor10to2)),
        showClockFace: false
      ))
        .frame(width: 300)
      Spacer()
      self.controls
      Spacer()
    }
  }

  private var landscapeBody: some View {
    HStack {
      VStack {
        Clock(viewModel: ClockViewModel(
          date: .constant(Date(timeIntervalSince1970: Self.timestampFor10to2)),
          showClockFace: false
        ))
          .frame(width: 300)
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
    Configuration()
  }
}
