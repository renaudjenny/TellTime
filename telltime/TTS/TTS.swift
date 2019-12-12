import Foundation
import Combine

enum TTS {
  struct State {
    var isSpeaking = false
    var speakingProgress = 0.0
    var rateRatio: Float = 1.0
  }

  enum Action {
    case changeRateRatio(Float)
    case tellTime(Date)
    case startSpeaking
    case stopSpeaking
    case changeSpeakingProgress(Double)
  }

  enum SideEffect: Effect {
    case subscribeToEngineIsSpeaking
    case subscribeToEngineSpeakingProgress

    func mapToAction() -> AnyPublisher<TTS.Action, Never> {
      switch self {
      case .subscribeToEngineIsSpeaking:
        return Current.tts.isSpeakingPublisher
          .map { $0 ? .startSpeaking : .stopSpeaking }
          .eraseToAnyPublisher()
      case .subscribeToEngineSpeakingProgress:
        return Current.tts.speakingProgressPublisher
          .map { .changeSpeakingProgress($0) }
          .eraseToAnyPublisher()
      }
    }
  }

  static let reducer: Reducer<TTS.State, TTS.Action> = Reducer { state, action in
    switch action {
    case let .changeRateRatio(rateRatio):
      state.rateRatio = rateRatio
      Current.tts.setRateRatio(rateRatio)
    case let .tellTime(date):
      Current.tts.speech(date)
    case .startSpeaking:
      state.isSpeaking = true
    case .stopSpeaking:
      state.isSpeaking = false
    case let .changeSpeakingProgress(speakingProgress):
      state.speakingProgress = speakingProgress
    }
  }
}

extension TTS {
  static func time(date: Date) -> String {
    Current.tts.time(date)
  }
}

extension TTS {
  struct World {
    var isSpeaking =  Engine.default.isSpeaking
    var isSpeakingPublisher = Engine.default.$isSpeaking
    var speakingProgressPublisher = Engine.default.$speakingProgress
    var setRateRatio = { Engine.default.rateRatio = $0 }
    var speech = { Engine.default.speech(date: $0) }
    var time = { Engine.default.time(date: $0) }
  }
}
