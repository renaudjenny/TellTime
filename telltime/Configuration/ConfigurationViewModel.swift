import SwiftUI
import Combine

final class ConfigurationViewModel: ObservableObject, Identifiable {
  @Published var deviceOrientation = UIDevice.current.orientation

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
