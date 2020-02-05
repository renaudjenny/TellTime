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

  static func subscribeToEngineIsSpeaking() -> AnyPublisher<App.Action, Never> {
    Current.tts.isSpeakingPublisher
      .map { $0 ? .tts(.startSpeaking) : .tts(.stopSpeaking) }
      .eraseToAnyPublisher()
  }

  static func subscribeToEngineSpeakingProgress() -> AnyPublisher<App.Action, Never> {
    Current.tts.speakingProgressPublisher
      .map { .tts(.changeSpeakingProgress($0)) }
      .eraseToAnyPublisher()
  }

  static func reducer(state: inout TTS.State, action: TTS.Action) {
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
