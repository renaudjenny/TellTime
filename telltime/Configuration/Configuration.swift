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
      Toggle(isOn: self.$configuration.showMinuteIndicators) {
        Text("Minute indicators")
      }
      Toggle(isOn: self.$configuration.showHourIndicators) {
        Text("Hour indicators")
      }
      Toggle(isOn: self.$configuration.showLimitedHourIndicators) {
        Text("Limited Hour texts")
      }
      Spacer()
    }
    .padding()
  }
}

struct Configuration_Previews: PreviewProvider {
  static var previews: some View {
    Configuration()
  }
}
