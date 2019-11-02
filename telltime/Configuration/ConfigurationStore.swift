import SwiftUI
import Combine

final class ConfigurationStore: ObservableObject {
  @Published var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
  @Published var showMinuteIndicators: Bool = true
  @Published var showHourIndicators: Bool = true
  @Published var showLimitedHourIndicators: Bool = false
  @Published var speechRateRatio: Float = 1.0
  @Published var clockStyle: ClockStyle = .classic

  private var disposables = Set<AnyCancellable>()

  init() {
    self.subscribe()
  }

  private func subscribe() {
    NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
      .sink(receiveValue: { notification in
        guard let device = notification.object as? UIDevice else { return }
        guard device.orientation.isValidInterfaceOrientation else { return }

        let isPhoneUpsideDown = device.orientation == .portraitUpsideDown && device.userInterfaceIdiom == .phone
        guard !isPhoneUpsideDown else { return }

        self.deviceOrientation = device.orientation
      })
      .store(in: &self.disposables)
  }
}
