import SwiftUI
import Combine

final class ConfigurationStore: ObservableObject {
  @Published var showMinuteIndicators: Bool = true
  @Published var showHourIndicators: Bool = true
  @Published var showLimitedHourIndicators: Bool = false
  @Published var speechRateRatio: Float = 1.0
  @Published var clockStyle: ClockStyle = .classic

  var showIndicators: Bool {
    self.showHourIndicators || self.showMinuteIndicators
  }
}
