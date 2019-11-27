import SwiftUI
import Combine

enum App {
  struct State {
    var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    var speechRateRatio: Float = 1.0
    var configuration: Configuration.State = Configuration.State()
    var clock: Clock.State = Clock.State()
    var tts: TTS.State = TTS.State()
  }

  enum Action {
    case rotateDevice(UIDeviceOrientation)
    case changeSpeechRateRatio(Float)
    case configuration(Configuration.Action)
    case clock(Clock.Action)
    case tts(TTS.Action)
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
          .map { App.Action.rotateDevice($0.orientation) }
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
    case let .rotateDevice(deviceOrientation):
      state.deviceOrientation = deviceOrientation
    case let .changeSpeechRateRatio(rateRatio):
      state.speechRateRatio = rateRatio
      state.tts.engine.rateRatio = rateRatio
    case let .configuration(action):
      Configuration.reducer.reduce(&state.configuration, action)
    case let .clock(action):
      Clock.reducer.reduce(&state.clock, action)
    case let.tts(action):
      TTS.reducer.reduce(&state.tts, action)
    }
  }
}
