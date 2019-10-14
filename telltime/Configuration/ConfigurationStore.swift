import SwiftUI

final class ConfigurationStore: ObservableObject {
  @Published var showMinuteIndicators: Bool = true
  @Published var showHourIndicators: Bool = true
  @Published var showLimitedHourIndicators: Bool = false
}
