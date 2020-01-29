import SwiftUI
import Combine

enum App {
  struct State {
    var deviceOrientation = Current.deviceOrientation
    var configuration = Configuration.State()
    var clock = Clock.State()
    var tts = TTS.State()
  }

  enum Action {
    case rotateDevice(UIDeviceOrientation)
    case configuration(Configuration.Action)
    case clock(Clock.Action)
    case tts(TTS.Action)
  }

  static func subscribeToOrientationChanged() -> AnyPublisher<App.Action, Never> {
    func isSupportedOrientationForDevice(_ device: UIDevice) -> Bool {
      let isValidOrientation = device.orientation.isValidInterfaceOrientation
      let isPhoneUpsideDown = device.orientation == .portraitUpsideDown && device.userInterfaceIdiom == .phone
      return isValidOrientation && !isPhoneUpsideDown
    }

    return Current.orientationDidChangePublisher
      .map({ notification -> UIDevice? in
        notification.object as? UIDevice
      })
      .compactMap { $0 }
      .filter(isSupportedOrientationForDevice)
      .map { App.Action.rotateDevice($0.orientation) }
      .eraseToAnyPublisher()
  }

  static func reducer(state: inout App.State, action: App.Action) {
    switch action {
    case let .rotateDevice(deviceOrientation):
      state.deviceOrientation = deviceOrientation
    case let .configuration(action):
      Configuration.reducer(state: &state.configuration, action: action)
    case let .clock(action):
      Clock.reducer(state: &state.clock, action: action)
    case let.tts(action):
      TTS.reducer(state: &state.tts, action: action)
    }
  }

  #if DEBUG
  static let previewStore = Store<App.State, App.Action>(initialState: App.State(), reducer: { _, _ in })
  #endif
}
