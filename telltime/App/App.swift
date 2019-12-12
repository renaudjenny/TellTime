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

  enum SideEffect: Effect {
    case subscribeToOrientationChanged
    case clock(Clock.SideEffect)
    case tts(TTS.SideEffect)

    func mapToAction() -> AnyPublisher<App.Action, Never> {
      switch self {
      case .subscribeToOrientationChanged:
        return Current.orientationDidChangePublisher
          .map({ notification -> UIDevice? in
            notification.object as? UIDevice
          })
          .compactMap { $0 }
          .filter(self.isSupportedOrientationForDevice)
          .map { App.Action.rotateDevice($0.orientation) }
          .eraseToAnyPublisher()
      case let .clock(effect):
        return effect.mapToAction()
          .map { App.Action.clock($0) }
          .eraseToAnyPublisher()
      case let .tts(effect):
        return effect.mapToAction()
          .map { App.Action.tts($0) }
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
    case let .configuration(action):
      Configuration.reducer.reduce(&state.configuration, action)
    case let .clock(action):
      Clock.reducer.reduce(&state.clock, action)
    case let.tts(action):
      TTS.reducer.reduce(&state.tts, action)
    }
  }

  #if DEBUG
  static let previewStore = Store<App.State, App.Action>(initialState: App.State(), reducer: Reducer { _, _ in })
  #endif
}
