import SwiftUI

struct Configuration: View {
  static let timestampFor10to2: TimeInterval = 3000
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    VStack(spacing: 25.0) {
      Clock(viewModel: ClockViewModel(
        date: .constant(Date(timeIntervalSince1970: Self.timestampFor10to2)),
        showClockFace: false
      ))
        .frame(width: 300)
      Spacer()
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
      Spacer()
    }
    .padding()
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
