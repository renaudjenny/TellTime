import SwiftUI
import Combine

enum App {
  struct State {
    var configuration = Configuration.State()
    var clock = Clock.State()
    var tts = TTS.State()
  }

  enum Action {
    case configuration(Configuration.Action)
    case clock(Clock.Action)
    case tts(TTS.Action)
  }

  static func reducer(state: inout App.State, action: App.Action) {
    switch action {
    case let .configuration(action):
      Configuration.reducer(state: &state.configuration, action: action)
    case let .clock(action):
      Clock.reducer(state: &state.clock, action: action)
    case let.tts(action):
      TTS.reducer(state: &state.tts, action: action)
    }
  }

    #if DEBUG
    static func previewStore(modifyState: (inout App.State) -> Void) -> Store<App.State, App.Action> {
        var state = App.State()
        modifyState(&state)
        return .init(initialState: state, reducer: { _, _ in })
    }

    static let previewStore = App.previewStore { _ in }
    #endif
}
