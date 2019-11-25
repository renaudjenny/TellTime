import SwiftUI
import Combine

enum App {
  struct State {
    var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
  }

  enum Action {
    case change(deviceOrientation: UIDeviceOrientation)
  }

  enum SideEffect: Effect {
    case subscribeToOrientationChanged

    func mapToAction() -> AnyPublisher<App.Action, Never> {
      switch self {
      case .subscribeToOrientationChanged:
        return NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .map({ notification -> UIDevice? in
            notification.object as? UIDevice
          })
          .compactMap { $0 }
          .filter(self.isSupportedOrientationForDevice)
          .map { App.Action.change(deviceOrientation: $0.orientation) }
          .eraseToAnyPublisher()
      }
    }

    private func isSupportedOrientationForDevice(_ device: UIDevice) -> Bool {
      let isValidOrientation = device.orientation.isValidInterfaceOrientation
      let isPhoneUpsideDown = device.orientation == .portraitUpsideDown && device.userInterfaceIdiom == .phone
      return isValidOrientation && !isPhoneUpsideDown
    }
  }

  static let reducer: Reducer<App.State, App.Action> = Reducer { state, action in
    switch action {
    case let .change(deviceOrientation):
      state.deviceOrientation = deviceOrientation
    }
  }
}
