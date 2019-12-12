import AVFoundation
import SwiftPastTen
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
        return engine.$isSpeaking
          .map { $0 ? .startSpeaking : .stopSpeaking }
          .eraseToAnyPublisher()
      case .subscribeToEngineSpeakingProgress:
        return engine.$speakingProgress
          .map { .changeSpeakingProgress($0) }
          .eraseToAnyPublisher()
      }
    }
  }

  static let reducer: Reducer<TTS.State, TTS.Action> = Reducer { state, action in
    switch action {
    case let .changeRateRatio(rateRatio):
      state.rateRatio = rateRatio
      engine.rateRatio = rateRatio
    case let .tellTime(date):
      engine.speech(date: date)
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
    engine.time(date: date)
  }
}

extension TTS {
  private static let engine = Engine()

  private final class Engine: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var speakingProgress: Double = 0.0

    var rateRatio: Float = 1.0
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let tellTimeEngine: TellTimeEngine = SwiftPastTen()

    override init() {
      super.init()
      self.speechSynthesizer.delegate = self
    }

    func speech(date: Date) {
      self.speech(text: self.time(date: date))
    }

    func time(date: Date) -> String {
      guard let time = try? self.tellTimeEngine.tell(time: .fromDate(date)) else {
        return ""
      }
      return time
    }

    private func speech(text: String) {
      let tellTimeText = try? self.tellTimeEngine.tell(time: text)
      let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: tellTimeText ?? text)
      speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
      speechUtterance.rate *= self.rateRatio
      self.speechSynthesizer.speak(speechUtterance)
      self.isSpeaking = true
    }

    func speechSynthesizer(
      _ synthesizer: AVSpeechSynthesizer,
      didStart utterance: AVSpeechUtterance
    ) {
      self.speakingProgress = 0.0
    }

    func speechSynthesizer(
      _ synthesizer: AVSpeechSynthesizer,
      didFinish utterance: AVSpeechUtterance
    ) {
      self.isSpeaking = false
      self.speakingProgress = 1.0
    }

    func speechSynthesizer(
      _ synthesizer: AVSpeechSynthesizer,
      willSpeakRangeOfSpeechString characterRange: NSRange,
      utterance: AVSpeechUtterance
    ) {
      let total = Double(utterance.speechString.count)
      let averageBound = [Double(characterRange.lowerBound), Double(characterRange.upperBound)]
        .reduce(0, +)/2
      self.speakingProgress = averageBound/total
    }
  }
}

private extension String {
  static func fromDate(_ date: Date) -> String {
    let minute = Current.calendar.component(.minute, from: date)
    let hour = Current.calendar.component(.hour, from: date)
    return Self.fromHour(hour, minute: minute)
  }

  private static func fromHour(_ hour: Int, minute: Int) -> String {
    let minute = minute > 9 ? "\(minute)" : "0\(minute)"
    let hour = hour > 9 ? "\(hour)" : "0\(hour)"
    return "\(hour):\(minute)"
  }
}
